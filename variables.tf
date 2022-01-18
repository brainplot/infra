variable "domain_name" {
  type        = string
  description = "Naked domain name (e.g. example.com)."
}

variable "region" {
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

variable "droplet_name" {
  type    = string
  default = null
}

variable "droplet_image" {
  type        = string
  description = "The Droplet image ID or slug (run `doctl compute image list --public` to list them)."
}

variable "droplet_size" {
  type        = string
  description = "The unique slug that indentifies the type of Droplet. You can find a list of available slugs on https://docs.digitalocean.com/reference/api/api-reference/#tag/Sizes."
}

variable "ssh_port" {
  type    = number
  default = 22
}

variable "https_port" {
  type    = number
  default = 443
}
