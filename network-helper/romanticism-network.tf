data "nutanix_cluster" "cluster" {
  provider = nutanix.AZ01
  name = var.nutanix_cluster
}

module "Management" {
  source              = "../modules/network"
  providers = {
    nutanix = nutanix.AZ01
  }

  nutanix_cluster     = var.nutanix_cluster
  subnet_name         = "Management"
  subnet_vlan         = 109
  subnet_ip           = "10.122.40.0"
  subnet_prefix       = "25"
  subnet_gateway      = "10.122.40.1"
  subnet_dns_list     = ["10.22.64.15","10.22.64.16"]
  subnet_search_list  = [""]
  subnet_pool_list    = ["10.122.40.30 10.122.40.34"]
}

# resource "nutanix_subnet" "external-connect" {

#   provider = nutanix.AZ01

#   cluster_uuid     = data.nutanix_cluster.cluster.id
#   name         = "external-connect"
#   subnet_type = "VLAN"
#   vlan_id         = 109
#   subnet_ip           = "10.122.40.0"
#   prefix_length       = "25"
#   default_gateway_ip      = "10.122.40.1"
#   is_external = true
#   enable_nat = false
#   ip_config_pool_list_ranges = ["10.122.40.20 10.122.40.29"]
# }

module "User1" {
  source              = "../modules/network"
  providers = {
    nutanix = nutanix.AZ01
  }

  nutanix_cluster     = var.nutanix_cluster
  subnet_name         = "User1"
  subnet_vlan         = 107
  subnet_ip           = "10.122.7.0"
  subnet_prefix       = "24"
  subnet_gateway      = "10.122.7.1"
  subnet_dns_list     = ["10.22.64.15","10.22.64.16"]
  subnet_search_list  = [""]
  subnet_pool_list    = ["10.122.7.40 10.122.7.59"]
}

module "User2" {
  source              = "../modules/network"
  providers = {
    nutanix = nutanix.AZ01
  }
  nutanix_cluster     = var.nutanix_cluster
  subnet_name         = "User2"
  subnet_vlan         = 108
  subnet_ip           = "10.122.17.0"
  subnet_prefix       = "24"
  subnet_gateway      = "10.122.17.1"
  subnet_dns_list     = ["10.22.64.15","10.22.64.16"]
  subnet_search_list  = [""]
  subnet_pool_list    = ["10.122.17.140 10.122.17.149",
                          "10.122.17.160 10.122.17.169",
                          "10.122.17.210 10.122.17.250"]
}

module "Infrastructure" {
  source              = "../modules/network"
  providers = {
    nutanix = nutanix.AZ01
  }
  nutanix_cluster     = var.nutanix_cluster
  subnet_name         = "Infrastructure"
  subnet_vlan         = 110
  subnet_ip           = "10.122.40.128"
  subnet_prefix       = "26"
  subnet_gateway      = "10.122.40.129"
  subnet_dns_list     = ["10.22.64.15","10.22.64.16"]
  subnet_search_list  = [""]
  subnet_pool_list    = ["10.122.40.160 10.122.40.166"]
}

# module "User3" {
#   source              = "../modules/network"
#   providers = {
#     nutanix = nutanix.AZ01
#   }
#   nutanix_cluster     = var.nutanix_cluster
#   subnet_name         = "User3"
#   subnet_vlan         = 125
#   subnet_ip           = "10.124.74.0"
#   subnet_prefix       = "24"
#   subnet_gateway      = "10.124.74.1"
#   subnet_dns_list     = ["10.22.64.15","10.22.64.16"]
#   subnet_search_list  = [""]
#   subnet_pool_list    = ["10.124.74.130 10.124.74.149"]
# }

