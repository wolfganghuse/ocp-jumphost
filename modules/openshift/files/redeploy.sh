rm -rf ocp.ready
openshift-install destroy cluster
rm -rf .openshift*
rm -rf manifests
rm -rf auth
rm -rf tls
rm -rf terraform
rm -rf metadata.json
cp install-config.yaml.x install-config.yaml
sh create_ocp.sh
return_code=$?
# Check if return code is different than 0
if [ $return_code -ne 0 ]; then
    echo "There was an error running create_ocp.sh. Return code: $return_code"
    exit 1
else
    echo "Cluster successfully installed"
    touch ocp.ready
fi