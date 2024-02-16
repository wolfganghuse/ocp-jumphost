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
touch ocp.ready