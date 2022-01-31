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

output "ansible_inventory" {
  sensitive = true
  value = templatefile("${path.module}/templates/ansible_inventory.yaml.tftpl", {
    # Vars
    ansible_port                 = var.ssh_port,
    ansible_ssh_user             = var.admin_user,
    certbot_cloudflare_api_token = cloudflare_api_token.certbot.value,
    # Groups
    webservers = [
      local.web_ipv4_address,
    ],
  })
}
