terraform{
  required_providers{
    nutanix = {
      source = "nutanix/nutanix"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}