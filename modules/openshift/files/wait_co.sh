#!/bin/bash

# Check if a clusteroperator name was provided as a command line argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <clusteroperator_name>"
    exit 1
fi

clusteroperator_name="$1"

# Function to check if the provided clusteroperator is available and not progressing
clusteroperator_status_check() {
    # Get the clusteroperator availability status
    available_status=$(oc --kubeconfig=auth/kubeconfig get clusteroperator "$clusteroperator_name" -o=jsonpath='{.status.conditions[?(@.type=="Available")].status}')

    # Get the clusteroperator progressing status
    progressing_status=$(oc --kubeconfig=auth/kubeconfig get clusteroperator "$clusteroperator_name" -o=jsonpath='{.status.conditions[?(@.type=="Progressing")].status}')

    if [[ "$available_status" == "True" && "$progressing_status" == "False" ]]; then
        return 0    # Clusteroperator is available and not progressing
    else
        return 1    # Clusteroperator is either not available or still progressing
    fi
}

# Loop until the specified clusteroperator is available and not progressing
while ! clusteroperator_status_check; do
    echo "Waiting for '$clusteroperator_name' clusteroperator to be available and not progressing..."
    sleep 30  # Wait for 30 seconds before checking again
done

echo "$clusteroperator_name clusteroperator is available and not progressing. Exiting."