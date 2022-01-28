provider "digitalocean" {
  token = var.digitalocean_token
}

locals {
  web_ipv4_address = digitalocean_droplet.web.ipv4_address
  web_ipv6_address = digitalocean_droplet.web.ipv6_address
}

resource "digitalocean_project" "website" {
  name        = var.project_name
  description = var.project_description
  purpose     = var.project_purpose
  environment = var.project_environment
  resources = [
    digitalocean_droplet.web.urn,
  ]
}

resource "digitalocean_vpc" "website" {
  name     = var.domain_name
  region   = var.region
  ip_range = var.vpc_ip_range
}

resource "digitalocean_ssh_key" "web" {
  name       = "https.${var.domain_name}"
  public_key = var.ssh_public_key
}

locals {
  web_tags = distinct(var.web_tags)
}

resource "digitalocean_tag" "web_tags" {
  count = length(local.web_tags)
  name  = local.web_tags[count.index]
}

resource "digitalocean_droplet" "web" {
  image             = var.web_droplet_image
  name              = var.web_droplet_name != null ? var.web_droplet_name : var.domain_name
  region            = var.region
  size              = var.web_droplet_size
  ipv6              = true
  graceful_shutdown = true
  droplet_agent     = true
  user_data = templatefile("${path.module}/templates/userdata.tftpl", {
    admin_user     = var.admin_user
    ssh_port       = var.ssh_port
    ssh_public_key = digitalocean_ssh_key.web.public_key
  })

  vpc_uuid = digitalocean_vpc.website.id
  ssh_keys = [digitalocean_ssh_key.web.fingerprint]
  tags     = digitalocean_tag.web_tags.*.id
}

locals {
  all_ports     = "1-65535"
  all_addresses = ["0.0.0.0/0", "::/0"]
}

resource "digitalocean_firewall" "web" {
  name = "https.${var.domain_name}"
  tags = digitalocean_tag.web_tags.*.id

  inbound_rule {
    protocol         = "tcp"
    port_range       = var.ssh_port
    source_addresses = local.all_addresses
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = var.https_port
    source_addresses = local.all_addresses
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = local.all_addresses
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = local.all_ports
    destination_addresses = local.all_addresses
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = local.all_ports
    destination_addresses = local.all_addresses
  }

  outbound_rule {
    protocol              = "icmp"
    port_range            = local.all_ports
    destination_addresses = local.all_addresses
  }
}
