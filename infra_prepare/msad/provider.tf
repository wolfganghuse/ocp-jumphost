terraform{
  required_providers{
    nutanix = {
      source = "nutanix/nutanix"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "nutanix" {
  alias     = "AZ01"
  username  = var.PC_USER
  password  = var.PC_PASS
  endpoint  = var.PC_ENDPOINT
  insecure  = true
  port      = 9440
}
