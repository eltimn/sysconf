locals {
  # doctl compute ssh-key list
  sshKeyId = 44528459
}

# resource "digitalocean_droplet" "nixos-test" {
#   image    = digitalocean_custom_image.nixos.id
#   name     = "nixos-test-01"
#   region   = var.region
#   size     = "s-1vcpu-1gb"
#   ssh_keys = [ local.sshKeyId ]
# }
