# Cloudflare SSL/TLS Settings
resource "cloudflare_zone_settings_override" "eltimn_settings" {
  zone_id = var.cloudflare_zone_id

  settings {
    # Set SSL mode to "full" to allow proxying to DigitalOcean app
    # which has a wildcard cert for *.ondigitalocean.app
    ssl = "full"
  }
}
