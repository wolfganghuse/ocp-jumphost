
# Create Operator Group
cat <<EOF | oc  --kubeconfig=auth/kubeconfig create -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  generateName: openshift-cluster-csi-drivers
  namespace: openshift-cluster-csi-drivers
spec:
  targetNamespaces:
  - openshift-cluster-csi-drivers
  upgradeStrategy: Default
EOF

if [[ -z "$(oc  --kubeconfig=auth/kubeconfig get packagemanifests | grep nutanix)" || $CSI_BETA == "true" ]]; then  echo "Can't find CSI operator version that meet the OCP version"
  cat <<EOF | oc  --kubeconfig=auth/kubeconfig apply -f -
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

  start_time=$(date +%s)
  while true; do
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))

    if [[ $(oc  --kubeconfig=auth/kubeconfig get catalogsource nutanix-csi-operator-beta -n openshift-marketplace -o 'jsonpath={..status.connectionState.lastObservedState}') == "READY" ]]; then
      echo "CatalogSource is now READY."
      break
    fi

    if [[ ${elapsed_time} -ge ${resource_timeout_seconds} ]]; then
      echo "Timeout: Nutanix CSI CatalogSource did not become READY within ${resource_timeout_seconds} seconds."
      exit 1
    fi

    echo "Waiting for CatalogSource to be READY..."
    sleep 5s
  done
fi

starting_csv=$(oc  --kubeconfig=auth/kubeconfig get packagemanifests nutanixcsioperator -o jsonpath=\{.status.channels[*].currentCSV\})
source=$(oc  --kubeconfig=auth/kubeconfig get packagemanifests nutanixcsioperator -o jsonpath=\{.status.catalogSource\})
source_namespace=$(oc  --kubeconfig=auth/kubeconfig get packagemanifests nutanixcsioperator -o jsonpath=\{.status.catalogSourceNamespace\})

cat <<EOF | oc  --kubeconfig=auth/kubeconfig apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: nutanixcsioperator
  namespace: openshift-cluster-csi-drivers
spec:
  channel: stable
  installPlanApproval: Automatic
  name: nutanixcsioperator
  source: ${source}
  sourceNamespace: ${source_namespace}
  startingCSV: ${starting_csv}
EOF

start_time=$(date +%s)
while true; do
  current_time=$(date +%s)
  elapsed_time=$((current_time - start_time))

  if [[ $(oc  --kubeconfig=auth/kubeconfig get subscription nutanixcsioperator -n openshift-cluster-csi-drivers -o 'jsonpath={..status.state}') == "AtLatestKnown" ]]; then
    echo "Subscription is now ready."
    break
  fi

  if [[ ${elapsed_time} -ge ${resource_timeout_seconds} ]]; then
    echo "Timeout: Nutanix operator subscription did not become ready within ${resource_timeout_seconds} seconds."
    exit 1
  fi

  echo "Waiting for Subscription to be ready..."
  sleep 5
done

# Create a NutanixCsiStorage resource to deploy your driver
cat <<EOF | oc  --kubeconfig=auth/kubeconfig create -f -
apiVersion: crd.nutanix.com/v1alpha1
kind: NutanixCsiStorage
metadata:
  name: nutanixcsistorage
  namespace: openshift-cluster-csi-drivers
spec: {}
EOF

cat <<EOF | oc  --kubeconfig=auth/kubeconfig create -f -
apiVersion: v1
kind: Secret
metadata:
  name: ntnx-secret
  namespace: openshift-cluster-csi-drivers
stringData:
  # prism-element-ip:prism-port:admin:password
  key: ${PE_HOST}:${PE_PORT}:${PE_USERNAME}:${PE_PASSWORD}
EOF

NUTANIX_STORAGE_CONTAINER=SelfServiceContainer

cat <<EOF | oc  --kubeconfig=auth/kubeconfig create -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: nutanix-volume
  annotations:
    storageclass.kubernetes.io/is-default-class: 'true'
provisioner: csi.nutanix.com
parameters:
  csi.storage.k8s.io/fstype: ext4
  csi.storage.k8s.io/provisioner-secret-namespace: openshift-cluster-csi-drivers
  csi.storage.k8s.io/provisioner-secret-name: ntnx-secret
  storageContainer: ${NUTANIX_STORAGE_CONTAINER}
  csi.storage.k8s.io/controller-expand-secret-name: ntnx-secret
  csi.storage.k8s.io/node-publish-secret-namespace: openshift-cluster-csi-drivers
  storageType: NutanixVolumes
  csi.storage.k8s.io/node-publish-secret-name: ntnx-secret
  csi.storage.k8s.io/controller-expand-secret-namespace: openshift-cluster-csi-drivers
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: Immediate
EOF