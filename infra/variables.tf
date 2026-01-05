variable "cloudflare_api_token" {
  description = "The Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "The Cloudflare Zone ID for eltimn.com"
  type        = string
}

variable "do_access_token" {
  description = "The Digital Ocean API token"
  type        = string
  sensitive   = true
}

variable "do_custom_image_name" {
  description = "Name of the Digital Ocean custom image"
  type = string
  default = "nixos-25.11-v3"
}

variable "region" {
  description = "The region to use."
  type = string
  default = "nyc3"
}

# variable "home_ip" {
#   description = "IP address of my home."
#   type = string
# }
