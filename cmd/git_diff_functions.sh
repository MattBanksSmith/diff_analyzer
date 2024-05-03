#!/bin/bash

extract_package_and_function() {
    local diff_output="$1"

    local package_name
    local package_path
    local current_function
    local current_function
    local functions=()

    while IFS= read -r line; do
        # Debug: Print the current line being processed
        #echo "Processing line: $line"

        # Extract package path from the line starting with "+++"0
        if [[ $line =~ ^\+\+\+ ]]; then
            package_path=$(echo "$line" | cut -d' ' -f2)
            package_path=${package_path:2}  # Remove the first two characters (a/ or b/)
            package_path=$(dirname "$package_path")
        elif [[ $line =~ ^@@[[:space:]]+-[[:digit:]]+,[[:digit:]]+[[:space:]]+\+[[:digit:]]+,[[:digit:]]+.*package[[:space:]]+([[:alnum:]_\.]+) ]]; then
            package_name="${BASH_REMATCH[1]}"
        elif [[ $line =~ [[:space:]]*func[[:space:]]+([[:alnum:]_]+)[[:space:]]*\( ]]; then
            current_function="${BASH_REMATCH[1]}"
        elif [[ $line =~ [[:space:]]*func[[:space:]]*\(([[:alnum:]_]+)[[:space:]]*\*?([[:alnum:]_]+)\)[[:space:]]*([[:alnum:]_]+)[[:space:]]*\( ]]; then
              #receiver="${BASH_REMATCH[1]}"
              receiver_type="${BASH_REMATCH[2]}"
              function_name="${BASH_REMATCH[3]}"
              current_function="${receiver_type}).${function_name}"
        elif [[ $line =~ ^[+-] ]]; then
            if [[ ! -z "$current_function" ]]; then
                functions+=("${package_path}.${current_function}")
                current_function=""
            fi
        fi
    done <<< "$diff_output"

    for func in "${functions[@]}"; do
      echo "$func"
    done
}

find_to_graph_nodes() {
    local node_input="$1"

    local graph_output="$2"
    local nodes=()

    while IFS= read -r line; do
      grep_result=$(echo "$graph_output" | grep "$line"  2>&1)

      if [ -z "$grep_result" ]; then
        continue
      fi

      nodes+=("$grep_result")
    done <<< "$node_input"

    for node in "${nodes[@]}"; do
      echo "$node"
    done
}

reverse_graph_search() {
    local node="$1"
    local graph="$2"
    local results=()

    while IFS= read -r line; do
      if [ -z "$line" ]; then
        continue
      fi
      result=$(echo "$graph" | digraph reverse "$line")
      results+=("$result")
    done <<< "$node"

    local as_string
    as_string=$(printf "%s\n" "${results[@]}")

    local deduped
    deduped=$(echo "$as_string" | sort -u)

    for d in "${deduped[@]}"; do
      echo "$d"
    done
}

# Check if merge request identifier is provided
if [ -z "$1" ]; then
    echo "Please provide a merge request identifier (e.g., branch name, commit hash)."
    exit 1
fi
merge_request="$1"
#filter="$2"
# Execute from root repo, not cmd

graph=$(callgraph --format=digraph .)
graph_all_nodes=$(echo "$graph" | digraph nodes)
#echo "Step 1 Result: $graph_output"

diff_output=$(git diff --function-context "$merge_request")
#echo "Step 2 Result: $diff_output"

result=$(extract_package_and_function "$diff_output")
#echo "Step 3 Result: $result"

graph_nodes=$(find_to_graph_nodes "$result" "$graph_all_nodes")
#echo "Step 4 Result: $graph_nodes"

reverse_nodes=$(reverse_graph_search "$graph_nodes" "$graph")
#echo "Step 5 Result: $reverse_nodes"

echo "$reverse_nodes"