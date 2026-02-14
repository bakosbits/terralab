#!/bin/bash
# Fetch ready nodes from Nomad API and return as JSON
# Requires 'jq' installed
nodes=$(curl -s "${NOMAD_ADDR:-http://localhost:4646}/v1/nodes?filter=Status%3D%3D%22ready%22")
echo "$nodes" | jq -c '{ids: [.[].ID] | join(",")}'