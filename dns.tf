data "cloudflare_zone" "this" {
  name = var.OCP_BASEDOMAIN
}

resource "cloudflare_record" "API" {
  zone_id = data.cloudflare_zone.this.id
  name    = format("api.%s", var.OCP_SUBDOMAIN)
  value   = "${var.VPC == true ? var.OCP_API_VIP_EXTERNAL : var.OCP_API_VIP}" 
  type    = "A"
}

resource "cloudflare_record" "INGRESS" {
  zone_id = data.cloudflare_zone.this.id
  name    = format("*.apps.%s", var.OCP_SUBDOMAIN)
  value   = "${var.VPC == true ? var.OCP_INGRESS_VIP_EXTERNAL : var.OCP_INGRESS_VIP}" 
  type    = "A"
}

resource "cloudflare_record" "PC" {
  zone_id = data.cloudflare_zone.this.id
  name    = format("pc-%s", var.OCP_SUBDOMAIN)
  value   = var.PC_ENDPOINT
  type    = "A"
}