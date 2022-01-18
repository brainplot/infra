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

resource "digitalocean_ssh_key" "web" {
  name       = var.domain_name
  public_key = file("~/.ssh/${var.domain_name}.pub")
}

resource "digitalocean_droplet" "web" {
  image             = var.droplet_image
  name              = var.droplet_name != null ? var.droplet_name : var.domain_name
  region            = var.region
  size              = var.droplet_size
  ipv6              = true
  graceful_shutdown = true
  droplet_agent     = false
  user_data = templatefile("templates/userdata.tftpl", {
    admin_user = var.admin_user
    ssh_port   = var.ssh_port
  })

  vpc_uuid = digitalocean_vpc.website.id
  ssh_keys = [digitalocean_ssh_key.web.fingerprint]
}

locals {
  all_ports     = "1-65535"
  all_addresses = ["0.0.0.0/0", "::/0"]
}

resource "digitalocean_firewall" "web" {
  name        = var.domain_name
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
