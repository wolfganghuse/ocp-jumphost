cat <<EOF | oc --kubeconfig=auth/kubeconfig create -f -
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: image-registry-claim
  namespace: openshift-image-registry
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  storageClassName: nutanix-volume
EOF

oc --kubeconfig=auth/kubeconfig patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"managementState":"Managed","storage":{"pvc":{"claim":"image-registry-claim"}},"rolloutStrategy": "Recreate"}}'