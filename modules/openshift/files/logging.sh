cat <<EOF | oc --kubeconfig=auth/kubeconfig apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-monitoring-config
  namespace: openshift-monitoring
data:
  config.yaml: |
    enableUserWorkload: true
    alertmanagerMain:
      volumeClaimTemplate:
        spec:
          storageClassName: nutanix-volume
          resources:
            requests:
              storage: 20Gi
    prometheusK8s:
      retention: 15d
      volumeClaimTemplate:
        spec:
          storageClassName: nutanix-volume
          resources:
            requests:
              storage: 2000Gi
EOF