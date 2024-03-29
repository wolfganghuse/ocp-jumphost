ocp:
	terraform apply -state=state/${TF_VAR_ZONE}-${TF_VAR_OCP_SUBDOMAIN}-state.tfstate -target=module.openshift-cluster

redeploy:
	terraform destroy -target=module.openshift-cluster.null_resource.installer -target=module.openshift-cluster.null_resource.bastion_disconnected[0] -state=state/${TF_VAR_ZONE}-${TF_VAR_OCP_SUBDOMAIN}-state.tfstate
	terraform apply -target=module.openshift-cluster.null_resource.installer -target=module.openshift-cluster.null_resource.bastion_disconnected[0] -state=state/${TF_VAR_ZONE}-${TF_VAR_OCP_SUBDOMAIN}-state.tfstate
	
vm:
	
	terraform apply -target=nutanix_virtual_machine.installer -state=state/${TF_VAR_ZONE}-state.tfstate
	terraform apply -target=aws_route53_record.bastion -state=state/${TF_VAR_ZONE}-state.tfstate


prepare_infra:
	terraform -chdir=infra_prepare apply -state=state/${TF_VAR_ZONE}-state.tfstate

clean_vm:
	terraform destroy -target=module.openshift-cluster.null_resource.installer -target=module.openshift-cluster.null_resource.bastion_disconnected[0] -state=state/${TF_VAR_ZONE}-${TF_VAR_OCP_SUBDOMAIN}-state.tfstate
	terraform destroy -target=nutanix_virtual_machine.installer -state=state/${TF_VAR_ZONE}-state.tfstate

network:
	terraform apply -target=aws_route53_record.{API,INGRESS,PC} -state=state/${TF_VAR_ZONE}-state.tfstate
clean_network:
	terraform destroy -target=aws_route53_record.{API,INGRESS,PC} -state=state/${TF_VAR_ZONE}-state.tfstate
clean_zone:
	terraform destroy -state=state/${TF_VAR_ZONE}-state.tfstate
	rm state/${TF_VAR_ZONE}-state.tfstate*
refresh_certs:
	terraform destroy -target=module.openshift-cluster.module.cert_ocp.acme_certificate.certificate -state=state/${TF_VAR_ZONE}-${TF_VAR_OCP_SUBDOMAIN}-state.tfstate

refresh_infra_certs:
	terraform -chdir=infra_prepare destroy -target=acme_certificate.prismcentral -state=state/${TF_VAR_ZONE}-state.tfstate
	terraform -chdir=infra_prepare apply -target=acme_certificate.prismcentral -state=state/${TF_VAR_ZONE}-state.tfstate

status:
	terraform output -state=state/${TF_VAR_ZONE}-state.tfstate
