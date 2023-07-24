variable "PC_PASS" {
  type = string
}

variable "PC_USER" {
  type = string
}

variable "PC_ENDPOINT" {
  type = string
}

variable "subnet" {
  type = string
}

variable "bastion_fqdn" {
  type = string
}

variable "cluster" {
  type = string
}

variable "api_vip" {
  type = string
}

variable "ingress_vip" {
  type = string
}

variable "subdomain" {
  type = string
}

variable "basedomain" {
  type = string
}

variable "zone" {
  type = string
}

variable "container" {
  type = string
}

variable "peuser" {
  type = string
}

variable "pepass" {
  type = string
}

variable "controlplane_size" {
  type = string
}

variable "cluster_role" {
  type = string
}

variable "ssh_pub" {
  type = string
}

variable "ssh_priv" {
  type = string
}

variable "mirror" {
  type = bool
}

variable "mirror_host" {
  type = string
}

variable "mirror_repo" {
  type = string
}

variable "cloudflare_api_token" {
  type = string
}

variable "pullsecret" {
  type = string
}