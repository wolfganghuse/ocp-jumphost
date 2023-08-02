resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "wolfgang.huse@nutanix.com"
}

resource "acme_certificate" "prismcentral" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = format("%s.%s", var.ZONE,var.OCP_BASEDOMAIN)
  subject_alternative_names = [
    format("*.%s.%s", var.ZONE,var.OCP_BASEDOMAIN)
  ]

  dns_challenge {
    provider = "cloudflare"
    config = {
      CF_DNS_API_TOKEN     = var.cloudflare_api_token
    }
  }
  
}

resource "local_file" "prismcentral_cert" {
  content      = acme_certificate.prismcentral.certificate_pem
  filename = format("./%s/%s.crt", "certs", var.ZONE)
}
resource "local_file" "prismcentral_key" {
  content      = acme_certificate.prismcentral.private_key_pem
  filename = format("./%s/%s.key", "certs", var.ZONE)
}
resource "local_file" "prismcentral_ca" {
  content      = acme_certificate.prismcentral.issuer_pem
  filename = format("./%s/%s-ca.crt", "certs", var.ZONE)
}
