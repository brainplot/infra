output "admin_user" {
  value = var.admin_user
}

output "ssh_port" {
  value = var.ssh_port
}

output "web_ipv4_address" {
  value = local.web_ipv4_address
}

output "web_ipv6_address" {
  value = local.web_ipv6_address
}

output "certbot_cloudflare_api_token" {
  value     = cloudflare_api_token.certbot.value
  sensitive = true
}
