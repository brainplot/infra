terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

resource "digitalocean_project" "website" {
  name        = var.domain_name
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

locals {
  ssh_private_key_file = "~/.ssh/${var.domain_name}"
  ssh_public_key_file  = "${local.ssh_private_key_file}.pub"
}

resource "digitalocean_ssh_key" "web" {
  name       = "https.${var.domain_name}"
  public_key = file(pathexpand(local.ssh_public_key_file))
}

resource "digitalocean_droplet" "web" {
  image             = var.droplet_image
  name              = var.droplet_name != null ? var.droplet_name : var.domain_name
  region            = var.region
  size              = var.droplet_size
  ipv6              = true
  graceful_shutdown = true
  droplet_agent     = true
  user_data = templatefile("templates/userdata.tftpl", {
    admin_user     = var.admin_user
    ssh_port       = var.ssh_port
    ssh_public_key = digitalocean_ssh_key.web.public_key
  })

  vpc_uuid = digitalocean_vpc.website.id
  ssh_keys = [digitalocean_ssh_key.web.fingerprint]
}

locals {
  all_ports     = "1-65535"
  all_addresses = ["0.0.0.0/0", "::/0"]
}

resource "digitalocean_firewall" "web" {
  name        = "https.${var.domain_name}"
  droplet_ids = [digitalocean_droplet.web.id]

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
