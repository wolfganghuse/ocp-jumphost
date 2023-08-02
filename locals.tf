locals {
  bastion_fqdn = format("%s.%s.%s",var.installer_name,var.ZONE,var.OCP_BASEDOMAIN)
  pc_fqdn = format("pc.%s.%s", var.ZONE, var.OCP_BASEDOMAIN)
}