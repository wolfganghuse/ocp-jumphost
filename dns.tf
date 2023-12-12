resource "aws_route53_record" "bastion" {
  zone_id = "Z0807287146Q4KF4CRHAX"
  name    = format("%s.%s",var.installer_name,var.ZONE)
  type    = "A"
  ttl     = 300
  records = [nutanix_virtual_machine.installer.nic_list_status[0].ip_endpoint_list[0].ip]
}