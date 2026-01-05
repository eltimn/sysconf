# In Digital Ocean web console, custom images are under "Backups & Snapshots".
locals {
  imagesBucketName = "sysconf-images"
}

resource "digitalocean_custom_image" "nixos" {
  name    = var.do_custom_image_name
  url     = "https://${local.imagesBucketName}.${var.region}.digitaloceanspaces.com/${var.do_custom_image_name}.qcow2.gz"
  regions = [ var.region ]
  tags = [ "nixos", "sysconf" ]
  distribution = "Unknown OS" # NixOS
}
