resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "wolfgang.huse@nutanix.com"
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = var.common_name
  subject_alternative_names = var.subject_alternative_names

  dns_challenge {
    provider = "route53"
    config = {
      AWS_HOSTED_ZONE_ID = var.ZONE_ID
    }
  }
}





