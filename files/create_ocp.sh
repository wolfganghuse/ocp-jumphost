openshift-install create manifests
cp openshift-machine-api-nutanix-credentials-credentials.yaml manifests
openshift-install create ignition-configs
openshift-install create cluster
cp auth/kubeconfig ~/.kube/config