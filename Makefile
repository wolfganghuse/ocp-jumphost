ocp:
	tofu apply -state=state/${TF_VAR_ZONE}-${TF_VAR_OCP_SUBDOMAIN}-state.tfstate -target=module.openshift-cluster

redeploy:
	tofu destroy -target=module.openshift-cluster.null_resource.installer -target=module.openshift-cluster.null_resource.bastion_disconnected[0] -state=state/${TF_VAR_ZONE}-${TF_VAR_OCP_SUBDOMAIN}-state.tfstate
	tofu apply -target=module.openshift-cluster.null_resource.installer -target=module.openshift-cluster.null_resource.bastion_disconnected[0] -state=state/${TF_VAR_ZONE}-${TF_VAR_OCP_SUBDOMAIN}-state.tfstate
	
vm:
	
	tofu apply -target=nutanix_virtual_machine.installer -state=state/${TF_VAR_ZONE}-state.tfstate
	tofu apply -target=aws_route53_record.bastion -state=state/${TF_VAR_ZONE}-state.tfstate


prepare_infra:
	tofu -chdir=infra_prepare apply -state=state/${TF_VAR_ZONE}-state.tfstate

clean_vm:
	tofu destroy -target=module.openshift-cluster.null_resource.installer -target=module.openshift-cluster.null_resource.bastion_disconnected[0] -state=state/${TF_VAR_ZONE}-${TF_VAR_OCP_SUBDOMAIN}-state.tfstate
	tofu destroy -target=nutanix_virtual_machine.installer -state=state/${TF_VAR_ZONE}-state.tfstate

network:
	tofu apply -target=aws_route53_record.{API,INGRESS,PC} -state=state/${TF_VAR_ZONE}-state.tfstate
clean_network:
	tofu destroy -target=aws_route53_record.{API,INGRESS,PC} -state=state/${TF_VAR_ZONE}-state.tfstate
clean_zone:
	tofu destroy -state=state/${TF_VAR_ZONE}-state.tfstate
	rm state/${TF_VAR_ZONE}-state.tfstate*
refresh_certs:
	tofu destroy -target=module.openshift-cluster.module.cert_ocp.acme_certificate.certificate -state=state/${TF_VAR_ZONE}-${TF_VAR_OCP_SUBDOMAIN}-state.tfstate

refresh_infra_certs:
	tofu -chdir=infra_prepare destroy -target=acme_certificate.prismcentral -state=state/${TF_VAR_ZONE}-state.tfstate
	tofu -chdir=infra_prepare apply -target=acme_certificate.prismcentral -state=state/${TF_VAR_ZONE}-state.tfstate

status:
	tofu output -state=state/${TF_VAR_ZONE}-state.tfstate
