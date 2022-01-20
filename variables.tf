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

variable "ssh_public_key_file" {
  type = string
}

variable "ssh_port" {
  type    = number
  default = 22
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
