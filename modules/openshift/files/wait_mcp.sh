#!/bin/bash

# Function to check if any MCP is updating
mcp_is_updating() {
    # Get the MachineConfigPools status
    mcp_status=$(oc --kubeconfig=auth/kubeconfig get mcp -o=jsonpath='{.items[*].status.conditions[?(@.type=="Updating")].status}')

    # Check if any MCP has status "True" for "Updating"
    if echo "$mcp_status" | grep -q "True"; then
        return 0    # MCP is updating
    else
        return 1    # MCP is not updating
    fi
}

# Loop until no MCP is updating
while mcp_is_updating; do
    echo "Waiting for MCP to finish updating..."
    sleep 30  # Wait for 30 seconds before checking again
done

echo "No MCP is updating now. Exiting."