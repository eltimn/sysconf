locals {
  # doctl compute ssh-key list
  sshKeyId = 44528459
}

resource "digitalocean_droplet" "nixos-test" {
  image    = digitalocean_custom_image.nixos-26-05-v1.id
  name     = "nixos-test-01"
  region   = var.region
  size     = "s-1vcpu-1gb"
  ssh_keys = [local.sshKeyId]
}

resource "cloudflare_dns_record" "nixos_test" {
  zone_id = var.cloudflare_zone_id
  name    = "nixos-test-01"
  content = digitalocean_droplet.nixos-test.ipv4_address
  type    = "A"
  ttl     = 1
  proxied = false # Direct connection for SSH
}

resource "cloudflare_dns_record" "nginx" {
  zone_id = var.cloudflare_zone_id
  name    = "nginx"
  content = "nixos-test-01.eltimn.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true # Proxied IP for web services
}
