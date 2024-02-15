

module "openshift-cluster" {
  source              = "./modules/openshift"
  providers = {
    nutanix = nutanix.AZ01
  }

  depends_on = [
    data.terraform_remote_state.zone
  ]


  PC_USER           = var.PC_USER
  PC_PASS           = var.PC_PASS
  PC_ENDPOINT       = local.pc_fqdn
  PC_ENDPOINT_EXISTING_FQDN = var.PC_ENDPOINT_EXISTING_FQDN
  ssh_priv          = var.JUMPHOST_PRIVATE_SSH
  ssh_pub           = var.JUMPHOST_PUBLIC_SSH
  user              = "ubuntu"
  bastion_fqdn      = data.terraform_remote_state.zone.outputs.ip_address
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
  cluster_role      = var.cluster_role
  ocp_ver           = var.ocp_ver
  ZONE_ID           = var.ZONE_ID
  CSI_BETA          = var.BETA_CSI

  pullsecret        = var.pullsecret
}
