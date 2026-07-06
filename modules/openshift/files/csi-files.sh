kubectl --kubeconfig auth/kubeconfig apply -f - <<EOF
kind: Secret
apiVersion: v1
metadata:
  name: nutanix-csi-credentials-files
  namespace: openshift-cluster-csi-drivers
stringData:
  files-key: files-fqdn:user:pass
  key: 1.2.3.4:9440:admin:dummy
type: Opaque
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
    name: nai-nfs-storage
provisioner: csi.nutanix.com
parameters:
  dynamicProv: ENABLED
  nfsServerName: files
  csi.storage.k8s.io/provisioner-secret-name: nutanix-csi-credentials-files
  csi.storage.k8s.io/provisioner-secret-namespace: openshift-cluster-csi-drivers
  csi.storage.k8s.io/node-publish-secret-name: nutanix-csi-credentials-files
  csi.storage.k8s.io/node-publish-secret-namespace: openshift-cluster-csi-drivers
  csi.storage.k8s.io/controller-expand-secret-name: nutanix-csi-credentials-files
  csi.storage.k8s.io/controller-expand-secret-namespace: openshift-cluster-csi-drivers
  storageType: NutanixFiles
allowVolumeExpansion: true
EOF