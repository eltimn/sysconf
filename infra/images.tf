# In Digital Ocean web console, custom images are under "Backups & Snapshots".
locals {
  imagesBucketName = "sysconf-images"
}

resource "digitalocean_custom_image" "nixos" {
  name         = "nixos-25.11-v3"
  url          = "https://${local.imagesBucketName}.${var.region}.digitaloceanspaces.com/nixos-25.11-v3.qcow2.gz"
  regions      = [var.region]
  tags         = ["nixos", "sysconf"]
  distribution = "Unknown OS" # NixOS
}

resource "digitalocean_custom_image" "nixos-26-05-v1" {
  name         = "nixos-26.05-v1"
  url          = "https://${local.imagesBucketName}.${var.region}.digitaloceanspaces.com/nixos-26.05-v1.qcow2.gz"
  regions      = [var.region]
  tags         = ["nixos", "sysconf"]
  distribution = "Unknown OS" # NixOS
}
