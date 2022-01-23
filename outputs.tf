output "web_ipv4_address" {
  value = digitalocean_droplet.web.ipv4_address
}

output "web_ipv6_address" {
  value = digitalocean_droplet.web.ipv6_address
}

output "certbot_cloudflare_api_token" {
  value     = cloudflare_api_token.certbot.value
  sensitive = true
}
