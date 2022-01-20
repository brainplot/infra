variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_zone" "zone" {
  zone = var.domain_name
}

resource "cloudflare_record" "root_ipv4" {
  zone_id = cloudflare_zone.zone.id
  name    = var.domain_name
  value   = digitalocean_droplet.web.ipv4_address
  type    = "A"
}

resource "cloudflare_record" "root_ipv6" {
  zone_id = cloudflare_zone.zone.id
  name    = var.domain_name
  value   = digitalocean_droplet.web.ipv6_address
  type    = "AAAA"
}

resource "cloudflare_record" "www" {
  zone_id = cloudflare_zone.zone.id
  name    = "www"
  value   = cloudflare_record.root_ipv4.hostname
  type    = "CNAME"
}
