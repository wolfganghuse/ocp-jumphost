data "cloudflare_zone" "this" {
  name = var.OCP_BASEDOMAIN
}

resource "cloudflare_record" "bastion" {
  zone_id = data.cloudflare_zone.this.id
  name    = format("%s.%s",var.installer_name,var.ZONE)
  value   = nutanix_virtual_machine.installer.nic_list_status[0].ip_endpoint_list[0].ip
  type    = "A"
}