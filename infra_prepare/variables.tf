variable "cloudflare_api_token" {
  type = string
}

variable "PC_PASS" {
  type = string
}

variable "PE_USER" {
  type = string
}

variable "PE_PASS" {
  type = string
}

variable "jumphost_nutanix_subnet" {
  type = string
}

variable "JUMPHOST_PRIVATE_SSH" {
  type = string
}

variable "JUMPHOST_PUBLIC_SSH" {
  type = string
}

variable "OCP_API_VIP" {
  type = string
}

variable "OCP_INGRESS_VIP" {
  type = string
}

variable "OCP_API_VIP_EXTERNAL" {
  type = string
}

variable "OCP_INGRESS_VIP_EXTERNAL" {
  type = string
}

variable "VPC" {
  type = bool
}

variable "ocp_basedir" {
  type = string
}



variable "OCP_BASEDOMAIN" {
  type = string
}

variable "OCP_SUBDOMAIN" {
  type = string
}

variable "PC_USER" {
  type = string
}

variable "PC_ENDPOINT" {
  type = string
}

variable "CONTAINER" {
  type = string
}

variable "nutanix_subnet" {
  type = string
}

variable "nutanix_cluster" {
  type = string
}

variable "JUMPHOST_IMAGE" {
  type = string
}

variable "USE_MIRROR" {
  type = bool
}

variable "MIRROR_REPO" {
  type = string
}

variable "MIRROR_HOST" {
  type = string
}
variable "installer_name" {
  type = string
}

variable "pullsecret" {
  type = string
}

variable "ZONE" {
  type = string
}

variable "ocp_ver" {
  type = string
}

variable "BETA_CSI" {
  type = string
}

variable "account_key_pem" {
  type = string
}

