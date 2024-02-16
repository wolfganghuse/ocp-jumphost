cat <<EOF | oc --kubeconfig=auth/kubeconfig create -f -
apiVersion: config.openshift.io/v1
kind: ImageTagMirrorSet
metadata:
    name: mirror-ocp
spec:
    imageTagMirrors:
        - mirrors:
            - harbor.infrastructure.dachlab.net/docker.io
          source: docker.io
        - mirrors:
            - harbor.infrastructure.dachlab.net/registry.k8s.io
          source: registry.k8s.io
        - mirrors:
            - harbor.infrastructure.dachlab.net/ghcr.io
          source: ghcr.io
        - mirrors:
            - harbor.infrastructure.dachlab.net/quay.io
          source: quay.io
        - mirrors:
            - harbor.infrastructure.dachlab.net/gcr.io
          source: gcr.io
EOF