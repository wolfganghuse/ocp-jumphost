variable "nutanix_cluster" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "subnet_vlan" {
  type = string
}
variable "subnet_ip" {
  type = string
  default = ""
}
variable "subnet_prefix" {
  type = string
  default = ""
}
variable "subnet_gateway" {
  type = string
  default = ""
}
variable "subnet_dns_list" {
  default = []
}
variable "subnet_search_list" {
  default = []
}
variable "subnet_pool_list" {
  default = []
}