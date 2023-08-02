openshift-install create manifests
cp openshift-machine-api-nutanix-credentials-credentials.yaml manifests
cp openshift-cloud-controller-manager-nutanix-credentials-credentials manifests
cp mco* manifests
openshift-install create ignition-configs
openshift-install create cluster
cp auth/kubeconfig ~/.kube/config