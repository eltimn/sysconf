# Cloudflare SSL/TLS Settings
# https://developers.cloudflare.com/terraform/tutorial/configure-https-settings/
resource "cloudflare_zone_setting" "ssl" {
  zone_id    = var.cloudflare_zone_id
  setting_id = "ssl"
  # Set SSL mode to "full" to allow proxying to DigitalOcean app
  # which has a wildcard cert for *.ondigitalocean.app
  value = "full"
}
