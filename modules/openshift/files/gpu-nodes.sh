oc --kubeconfig=auth/kubeconfig get $(oc --kubeconfig=auth/kubeconfig get machineset -A --output=name | head -n 1) -n openshift-machine-api -o json | \
sed 's/-worker/-gpu-nodepool/g' | \
jq '.spec.template.spec.providerSpec.value += {
  "gpus": [
    {
      "type": "Name",
      "name": "Lovelace 40S"
    }
  ]
}' | oc --kubeconfig=auth/kubeconfig create -f -