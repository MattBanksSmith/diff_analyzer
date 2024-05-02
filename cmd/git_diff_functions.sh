#!/bin/bash

# Function to extract package path and function name
extract_package_and_function() {
    local diff_output="$1"

    local package_name
    local package_path
    local current_function
    local functions=()

    while IFS= read -r line; do
        # Debug: Print the current line being processed
        # echo "Processing line: $line"

        # Extract package path from the line starting with "+++"0
        if [[ $line =~ ^\+\+\+ ]]; then
            package_path=$(echo "$line" | cut -d' ' -f2)
            package_path=${package_path:2}  # Remove the first two characters (a/ or b/)
            package_path=$(dirname "$package_path")
        elif [[ $line =~ ^@@[[:space:]]+-[[:digit:]]+,[[:digit:]]+[[:space:]]+\+[[:digit:]]+,[[:digit:]]+.*package[[:space:]]+([[:alnum:]_\.]+) ]]; then
            package_name="${BASH_REMATCH[1]}"
        elif [[ $line =~ [[:space:]]*func[[:space:]]+([[:alnum:]_]+)[[:space:]]*\( ]]; then
            current_function="${BASH_REMATCH[1]}"
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

# Check if merge request identifier is provided
if [ -z "$1" ]; then
    echo "Please provide a merge request identifier (e.g., branch name, commit hash)."
    exit 1
fi

# Example usage:
merge_request="$1"
diff_output=$(git diff --function-context "$merge_request")
extract_package_and_function "$diff_output"