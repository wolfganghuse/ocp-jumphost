provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "nutanix" {
  username  = var.PC_USER
  password  = var.PC_PASS
  endpoint  = var.PC_ENDPOINT
  insecure  = true
  port      = 9440
}
