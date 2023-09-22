ocp:
	terraform apply -state=state/${TF_VAR_ZONE}-${TF_VAR_OCP_SUBDOMAIN}-state.tfstate -target=module.openshift-cluster

redeploy:
	terraform destroy -target=module.openshift-cluster.null_resource.installer -target=module.openshift-cluster.null_resource.bastion_disconnected[0] -state=state/${TF_VAR_ZONE}-${TF_VAR_OCP_SUBDOMAIN}-state.tfstate
	terraform apply -target=module.openshift-cluster.null_resource.installer -target=module.openshift-cluster.null_resource.bastion_disconnected[0] -state=state/${TF_VAR_ZONE}-${TF_VAR_OCP_SUBDOMAIN}-state.tfstate
	
vm:
	
	terraform apply -target=nutanix_virtual_machine.installer -state=state/${TF_VAR_ZONE}-state.tfstate
	terraform apply -target=cloudflare_record.bastion -state=state/${TF_VAR_ZONE}-state.tfstate


prepare_infra:
	terraform -chdir=infra_prepare apply -state=state/${TF_VAR_ZONE}-state.tfstate

clean_vm:
	terraform destroy -target=nutanix_virtual_machine.installer -state=state/${TF_VAR_ZONE}-state.tfstate

network:
	terraform apply -target=cloudflare_record.{API,INGRESS,PC} -state=state/${TF_VAR_ZONE}-state.tfstate
clean_zone:
	terraform destroy -state=state/${TF_VAR_ZONE}-state.tfstate
	rm state/${TF_VAR_ZONE}-state.tfstate*

status:
	terraform output -state=state/${TF_VAR_ZONE}-state.tfstate
