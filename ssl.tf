resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "wolfgang.huse@nutanix.com"
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = format("%s.%s", var.OCP_SUBDOMAIN,var.OCP_BASEDOMAIN)
  subject_alternative_names = [
    format("api.%s.%s", var.OCP_SUBDOMAIN,var.OCP_BASEDOMAIN),
    format("*.apps.%s.%s", var.OCP_SUBDOMAIN,var.OCP_BASEDOMAIN),
    format("pc-%s.%s", var.OCP_SUBDOMAIN,var.OCP_BASEDOMAIN)
  ]

  dns_challenge {
    provider = "cloudflare"
    config = {
      CF_DNS_API_TOKEN     = var.cloudflare_api_token
    }
  }
}

resource "acme_certificate" "bastion" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = local.bastion_fqdn
  
  dns_challenge {
    provider = "cloudflare"
    config = {
      CF_DNS_API_TOKEN     = var.cloudflare_api_token
    }
  }
}





