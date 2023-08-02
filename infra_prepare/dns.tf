data "cloudflare_zone" "this" {
  name = var.OCP_BASEDOMAIN
}

resource "cloudflare_record" "PC" {
  zone_id = data.cloudflare_zone.this.id
  name    = format("pc.%s", var.ZONE)
  value   = var.PC_ENDPOINT
  type    = "A"
}