# Karbon cluster advanced manager

CLOUDFLARE ?= false
OCP_INSTALL ?= false
ocp:
	terraform apply -state=state/${TF_VAR_OCP_SUBDOMAIN}-state.tfstate

clean:
	terraform destroy -state=state/${TF_VAR_OCP_SUBDOMAIN}-state.tfstate
	rm state/${TF_VAR_OCP_SUBDOMAIN}-state.tfstate*

status:
	terraform output -state=state/${TF_VAR_OCP_SUBDOMAIN}-state.tfstate