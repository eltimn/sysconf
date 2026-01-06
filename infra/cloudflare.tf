# Cloudflare SSL/TLS Settings
# https://developers.cloudflare.com/terraform/tutorial/configure-https-settings/
resource "cloudflare_zone_setting" "ssl" {
  zone_id    = var.cloudflare_zone_id
  setting_id = "ssl"
  # Full (Strict) mode - Cloudflare Pages handles SSL natively
  value = "strict"
}

# resource "cloudflare_zone_setting" "always_use_https" {
#   zone_id    = var.cloudflare_zone_id
#   setting_id = "always_use_https"
#   value      = "on"
# }
# resource "cloudflare_zone_setting" "min_tls_version" {
#   zone_id    = var.cloudflare_zone_id
#   setting_id = "min_tls_version"
#   value      = "1.2"
# }
