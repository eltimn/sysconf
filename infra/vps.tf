locals {
  # doctl compute ssh-key list
  sshKeyId = 44528459
}

resource "digitalocean_droplet" "vps1" {
  image    = digitalocean_custom_image.nixos-26-05-v1.id
  name     = "vps1"
  region   = var.region
  size     = "s-1vcpu-1gb"
  ssh_keys = [local.sshKeyId]
}

resource "cloudflare_dns_record" "vps1" {
  zone_id = var.cloudflare_zone_id
  name    = "vps1"
  content = digitalocean_droplet.vps1.ipv4_address
  type    = "A"
  ttl     = 1
  proxied = false # Direct connection for SSH
}

resource "cloudflare_dns_record" "nginx" {
  zone_id = var.cloudflare_zone_id
  name    = "nginx"
  content = "vps1.eltimn.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true # Proxied IP for web services
}
