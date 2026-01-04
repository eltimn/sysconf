variable "cloudflare_api_token" {
  description = "The Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "The Cloudflare Zone ID for eltimn.com"
  type        = string
}

variable "digitalocean_token" {
  description = "The DigitalOcean API token"
  type        = string
  sensitive   = true
}

# variable "home_ip" {
#   description = "IP address of my home."
#   type = string
# }
