# Show IP address
output "ip_address" {
  value = nutanix_virtual_machine.installer.nic_list_status[0].ip_endpoint_list[0].ip
}