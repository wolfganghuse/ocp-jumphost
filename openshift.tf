
module "openshift-cluster" {
  source              = "./modules/openshift"
  providers = {
    nutanix = nutanix.AZ01
  }

    depends_on = [
    nutanix_virtual_machine.installer
  ]


  PC_USER           = var.PC_USER
  PC_PASS           = var.PC_PASS
  PC_ENDPOINT       = local.pc_fqdn
  
  ssh_priv          = var.JUMPHOST_PRIVATE_SSH
  ssh_pub           = var.JUMPHOST_PUBLIC_SSH
  user              = "ubuntu"
  bastion_fqdn      = nutanix_virtual_machine.installer.nic_list_status[0].ip_endpoint_list[0].ip
  basedomain        = var.OCP_BASEDOMAIN
  mirror            = var.USE_MIRROR
  mirror_repo       = var.MIRROR_REPO
  mirror_host       = var.MIRROR_HOST
  zone              = var.ZONE 
  subnet            = var.nutanix_subnet
  cluster           = var.nutanix_cluster
  api_vip           = var.OCP_API_VIP
  ingress_vip       = var.OCP_INGRESS_VIP
  
  subdomain         = var.OCP_SUBDOMAIN
  container         = var.CONTAINER
  peuser            = "admin"
  pepass            = "Nutanix.123"
  controlplane_size = "small"
  cluster_role      = "workload"
  ocp_ver           = var.ocp_ver

  BETA_CSI          = var.BETA_CSI
  pullsecret        = var.pullsecret

  cloudflare_api_token = var.cloudflare_api_token

  account_key_pem = var.account_key_pem
}
