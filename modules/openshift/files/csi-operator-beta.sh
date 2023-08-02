cat <<EOF | oc --kubeconfig=auth/kubeconfig create -f -
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: nutanix-csi-operator-beta
  namespace: openshift-marketplace
spec:
  displayName: Nutanix Beta
  publisher: Nutanix-dev
  sourceType: grpc
  image: quay.io/ntnx-csi/nutanix-csi-operator-catalog:latest
  updateStrategy:
    registryPoll:
      interval: 5m
EOF

cat <<EOF | oc --kubeconfig=auth/kubeconfig create -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  generateName: openshift-cluster-csi-drivers-
  namespace: openshift-cluster-csi-drivers
spec:
  targetNamespaces:
  - openshift-cluster-csi-drivers
  upgradeStrategy: Default
EOF

cat <<EOF | oc --kubeconfig=auth/kubeconfig create -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: nutanixcsioperator
  namespace: openshift-cluster-csi-drivers
spec:
  channel: stable
  installPlanApproval: Automatic
  name: nutanixcsioperator
  source: nutanix-csi-operator-beta
  sourceNamespace: openshift-marketplace
EOF

ATTEMPTS=0
ROLLOUT_STATUS_CMD="oc --kubeconfig=auth/kubeconfig wait --for=condition=available --timeout=120s -n openshift-cluster-csi-drivers deployments nutanix-csi-operator-controller-manager"
until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 12 ]; do
  $ROLLOUT_STATUS_CMD
  ATTEMPTS=$((attempts + 1))
  sleep 10
done
