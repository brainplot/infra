variable "domain_name" {
  type        = string
  description = "Naked domain name (e.g. example.com)."
}

variable "region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "project_description" {
  type    = string
  default = null
}

variable "project_purpose" {
  type    = string
  default = null
}

variable "project_environment" {
  type = string
}

variable "vpc_ip_range" {
  type        = string
  description = "The range of private addresses as defined in RFC1918."
}

variable "web_droplet_name" {
  type    = string
  default = null
}

variable "web_droplet_image" {
  type        = string
  description = "The Droplet image ID or slug (run `doctl compute image list --public` to list them)."
}

variable "web_droplet_size" {
  type        = string
  description = "The unique slug that indentifies the type of Droplet (run `doctl compute size list` to list them)."
}

variable "ssh_public_key" {
  type = string
}

variable "ssh_port" {
  type    = number
  default = 22
}

variable "http_port" {
  type    = number
  default = 80
}

variable "https_port" {
  type    = number
  default = 443
}

variable "admin_user" {
  type        = string
  description = "First unprivileged user to create on the newly-deployed machine."
  default     = "admin"
  validation {
    condition     = can(regex("^[a-z][-a-z0-9]*$", var.admin_user))
    error_message = "UNIX users must match the ^[a-z][-a-z0-9]*$ pattern."
  }
}

variable "web_tags" {
  type    = list(string)
  default = []
}

variable "digitalocean_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}
