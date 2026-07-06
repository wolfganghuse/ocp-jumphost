locals {
  domain = var.full_domain
}

module "cert" {
  source              = "../modules/ssl"
  
  ZONE_ID = var.ZONE_ID
  common_name = local.domain
  subject_alternative_names = [
    format("*.%s", local.domain),
    format("*.objects.%s", local.domain)
  ]
}      


resource "local_file" "cert" {
  content      = module.cert.certificate_pem
  filename = format("%s.crt", local.domain)
}
resource "local_file" "key" {
  content      = module.cert.private_key_pem
  filename = format("%s.key", local.domain)
}
resource "local_file" "ca" {
  content      = module.cert.issuer_pem
  filename = format("%s-ca.crt",local.domain)
}

resource "local_file" "fullchain" {
  content      =   "${module.cert.certificate_pem}\n${module.cert.issuer_pem}"
  filename = format("%s-fullchain.crt",local.domain)
}

