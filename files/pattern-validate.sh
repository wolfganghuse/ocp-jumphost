#!/bin/bash

# Check if two arguments are provided
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <CLUSTER1_NAME> <CLUSTER2_NAME>"
    exit 1
fi

# Assign clusters from command-line arguments
CLUSTER1="$1"
CLUSTER2="$2"

# Maximum number of retries
MAX_RETRIES=10

# Function to clean OpenShift
cleanup_ocp() {
    rm -rf ocp.ready
    openshift-install destroy cluster
    rm -rf .openshift*
    rm -rf manifests
    rm -rf auth
    rm -rf tls
    rm -rf terraform
    rm -rf metadata.json
}

# Function to create OpenShift
create_ocp() {
    cp install-config.yaml.x install-config.yaml
    openshift-install create manifests
    cp openshift-machine-api-nutanix-credentials-credentials.yaml manifests
    cp openshift-cloud-controller-manager-nutanix-credentials-credentials.yaml manifests
    cp mco* manifests
    openshift-install create ignition-configs
    openshift-install create cluster
    return_code=$?
    # Check if return code is different than 0
    if [ $return_code -ne 0 ]; then
        echo "There was an error creating the cluster. Return code: $return_code"
        exit 1
    else
        echo "Cluster successfully created!"
    fi
}

# Run Day2 actions
day2_actions() {
    sh certs.sh
    bash csi.sh
    sh imageregistry.sh
    sh logging.sh
    bash wait_co.sh ingress
    bash wait_co.sh kube-apiserver
    sh wait_mcp.sh
}

# Function to redeploy and wait for the cluster
redeploy_and_wait() {
    local cluster=$1

    cd ~/$cluster
    cleanup_ocp
    create_ocp
    day2_actions
}

# Function to final cleanup
cleanup_all() {
    local cluster=$1

    cd ~/$cluster
    cleanup_ocp
}

# Start redeployment and waiting in parallel for both clusters
redeploy_and_wait $CLUSTER1 &
PID1=$!

redeploy_and_wait $CLUSTER2 &
PID2=$!

# Wait for both processes to complete
wait $PID1 $PID2

echo "Both clusters are ready!"

echo "Cleaning Test Repo"
rm -rf ~/vp-qe-test-mcg/run/{logs,kube,pattern}
cd ~/vp-qe-test-mcg
git clone https://github.com/validatedpatterns/multicloud-gitops.git run/pattern
echo "Running tests..."
./run.sh -h /home/ubuntu/$CLUSTER1/auth -e /home/ubuntu/$CLUSTER2/auth -p /home/ubuntu/vp-qe-test-mcg/run/pattern
return_code=$?

# Check if return code is different than 0
if [ $return_code -ne 0 ]; then
    echo "There was an error running the test scripts. Return code: $return_code"
else
    echo "Test has successfully finished!"
    cleanup_all $CLUSTER1
    cleanup_all $CLUSTER2
    echo "Everything cleaned!"
fi