#!/bin/bash
packer build image-build-packer/.
terraform apply -target=nutanix_virtual_machine.msad
OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ansible-playbook ansible/msad.yaml -i hosts