terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

resource "digitalocean_project" "main" {
  name        = var.domain_name
  description = var.project_description
  purpose     = var.project_purpose
  environment = var.project_environment
  resources = [
    digitalocean_droplet.main.urn,
  ]
}

resource "digitalocean_vpc" "main" {
  name     = var.domain_name
  region   = var.region
  ip_range = var.vpc_ip_range
}

resource "digitalocean_ssh_key" "main" {
  name       = var.domain_name
  public_key = file("~/.ssh/${var.domain_name}.pub")
}

resource "digitalocean_droplet" "main" {
  image             = var.droplet_image
  name              = var.droplet_name != null ? var.droplet_name : var.domain_name
  region            = var.region
  size              = var.droplet_size
  ipv6              = true
  graceful_shutdown = true
  droplet_agent     = true
  user_data = templatefile("templates/userdata.tftpl", {
    admin_user = var.admin_user
    ssh_port   = var.ssh_port
  })

  vpc_uuid = digitalocean_vpc.main.id
  ssh_keys = [digitalocean_ssh_key.main.fingerprint]
}

locals {
  all_ports     = "1-65535"
  all_addresses = ["0.0.0.0/0", "::/0"]
}

resource "digitalocean_firewall" "main" {
  name        = var.domain_name
  droplet_ids = [digitalocean_droplet.main.id]

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
