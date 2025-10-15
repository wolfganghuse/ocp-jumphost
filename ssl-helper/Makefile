# Usage:
#   make DOMAIN=abc.org plan
#   make DOMAIN=abc.org apply
#   make DOMAIN=abc.org destroy

DOMAIN ?= example.com
STATE_DIR = .tfstates/$(DOMAIN)
TFDIR = .

.PHONY: init plan apply destroy clean

init:
	mkdir -p $(STATE_DIR)
	tofu -chdir=$(TFDIR) init -backend-config="path=$(STATE_DIR)/terraform.tfstate"

plan: init
	tofu -chdir=$(TFDIR) plan \
		-state=$(STATE_DIR)/terraform.tfstate \
		-var="full_domain=$(DOMAIN)"

apply: init
	tofu -chdir=$(TFDIR) apply \
		-state=$(STATE_DIR)/terraform.tfstate \
		-var="full_domain=$(DOMAIN)" 

destroy: init
	tofu -chdir=$(TFDIR) destroy \
		-state=$(STATE_DIR)/terraform.tfstate \
		-var="full_domain=$(DOMAIN)" 

clean:
	rm -rf .terraform $(TFDIR)/.terraform $(TFDIR)/.terraform.lock.hcl $(STATE_DIR)
