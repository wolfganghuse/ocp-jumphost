data "nutanix_cluster" "cluster" {
  name = var.nutanix_cluster
}

resource "nutanix_subnet" "subnet" {
  cluster_uuid = data.nutanix_cluster.cluster.id

  # General Information
  name        = var.subnet_name
  vlan_id     = var.subnet_vlan
  subnet_type = "VLAN"

  # Managed L3 Networks
  # This bit is only needed if you intend to turn on IPAM
  prefix_length = var.subnet_prefix

  default_gateway_ip = var.subnet_gateway
  subnet_ip          = var.subnet_ip

  dhcp_domain_name_server_list = var.subnet_dns_list
  dhcp_domain_search_list      = var.subnet_search_list
  ip_config_pool_list_ranges = var.subnet_pool_list

}