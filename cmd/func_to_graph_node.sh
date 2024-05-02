#!/bin/bash

find_to_graph_nodes() {
    local node_input="$1"
    local digraph_file="$2"
    local nodes=()

    while IFS= read -r line; do
      grep_result=$(grep "$line" "$digraph_file" 2>&1)

      if [ "$grep_result" -eq "" ]; then
        continue
      fi

      nodes+=grep_result

    done <<< "$node_input"

    for node in "${nodes[@]}"; do

    done
}
