# DO Spaces bucket for image storage
resource "digitalocean_spaces_bucket" "sysconf" {
  name   = "sysconf-images"
  region = "nyc3"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "cleanup-old-images"
    enabled = true

    expiration {
      days = 210
    }

    noncurrent_version_expiration {
      days = 30
    }
  }
}

output "spaces_bucket_name" {
  value = digitalocean_spaces_bucket.sysconf.name
}

output "spaces_bucket_url" {
  value = "https://${digitalocean_spaces_bucket.sysconf.name}.${digitalocean_spaces_bucket.sysconf.region}.digitaloceanspaces.com"
}
