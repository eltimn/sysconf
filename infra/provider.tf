# https://search.opentofu.org/provider/cloudflare/cloudflare/latest
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# https://search.opentofu.org/provider/opentofu/digitalocean/latest
provider "digitalocean" {
  token = var.do_access_token
}
