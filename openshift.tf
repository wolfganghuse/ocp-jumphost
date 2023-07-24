
module "openshift-cluster" {
  source              = "./modules/openshift"
  providers = {
    nutanix = nutanix.AZ01
  }

  PC_USER           = var.PC_USER
  PC_PASS           = var.PC_PASS
  PC_ENDPOINT       = "az01pc01.ocpnvd.dachlab.net"
  
  ssh_priv          = var.JUMPHOST_PRIVATE_SSH
  ssh_pub           = var.JUMPHOST_PUBLIC_SSH
  bastion_fqdn      = format("%s.%s.%s",var.bastion_name,var.ZONE,var.BASE_DOMAIN)
  basedomain        = var.BASE_DOMAIN
  mirror_repo       = var.MIRROR_REPO
  mirror_host       = var.MIRROR_HOST
  zone              = var.ZONE 
  subnet            = "AZ01MGMT01VLAN40"
  cluster           = "AZ01MGMT01"
  api_vip           = "10.44.140.8"
  ingress_vip       = "10.44.140.9"
  subdomain         = "az01ocp-hub"
  container         = "ocp"
  peuser            = "admin"
  pepass            = "Nutanix.123"
  controlplane_size = "small"
  cluster_role      = "hub"
  mirror            = false
  pullsecret        = var.pullsecret

  cloudflare_api_token = var.cloudflare_api_token
}
