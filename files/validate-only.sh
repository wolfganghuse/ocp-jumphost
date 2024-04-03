#!/bin/bash

# Check if two arguments are provided
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <CLUSTER1_NAME> <CLUSTER2_NAME>"
    exit 1
fi

# Assign clusters from command-line arguments
CLUSTER1="$1"
CLUSTER2="$2"

echo "Cleaning Test Repo"
rm -rf ~/vp-qe-test-mcg/run/{logs,kube,pattern}
cd ~/vp-qe-test-mcg
git clone https://github.com/validatedpatterns/multicloud-gitops.git run/pattern
echo "Running tests..."
./run.sh -h /home/ubuntu/$CLUSTER1/auth -e /home/ubuntu/$CLUSTER2/auth -p /home/ubuntu/vp-qe-test-mcg/run/pattern
return_code=$?
echo Validate script returned: $return_code
# Check if return code is different than 0
if [ $return_code -ne 0 ]; then
    echo "There was an error running the test scripts. Return code: $return_code"
else
    echo "Test has successfully finished!"
fi