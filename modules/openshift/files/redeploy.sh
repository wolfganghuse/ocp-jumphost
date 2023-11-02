rm -rf ocp.ready
openshift-install destroy cluster
cp install-config.yaml.x install-config.yaml
sh create_ocp.sh
touch ocp.ready