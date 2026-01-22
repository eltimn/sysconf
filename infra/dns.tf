# A Records
# https://search.opentofu.org/provider/cloudflare/cloudflare/latest/docs/resources/dns_record

# resource "cloudflare_dns_record" "home" {
#   zone_id = var.cloudflare_zone_id
#   name    = "home"
#   content = var.home_ip
#   type    = "A"
#   proxied = true
# }

# resource "cloudflare_dns_record" "nixos_test" {
#   zone_id = var.cloudflare_zone_id
#   name    = "nixos-test-01"
#   content = digitalocean_droplet.nixos-test.ipv4_address
#   type    = "A"
#   ttl     = 1
#   proxied = false # Direct connection for SSH
# }

# resource "cloudflare_dns_record" "nginx" {
#   zone_id = var.cloudflare_zone_id
#   name    = "nginx"
#   content = "nixos-test-01.eltimn.com" # Points to proxied IP for web services
#   type    = "CNAME"
#   ttl     = 1
#   proxied = false
# }

# CNAME Records
resource "cloudflare_dns_record" "root" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  content = "${cloudflare_pages_project.eltimn.name}.pages.dev"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "fm1_domainkey" {
  zone_id = var.cloudflare_zone_id
  name    = "fm1._domainkey"
  content = "fm1.eltimn.com.dkim.fmhosted.com"
  type    = "CNAME"
  ttl     = 1
  proxied = false
  comment = "DKIM record for Fastmail"
}

resource "cloudflare_dns_record" "fm2_domainkey" {
  zone_id = var.cloudflare_zone_id
  name    = "fm2._domainkey"
  content = "fm2.eltimn.com.dkim.fmhosted.com"
  type    = "CNAME"
  ttl     = 1
  proxied = false
  comment = "DKIM record for Fastmail"
}

resource "cloudflare_dns_record" "fm3_domainkey" {
  zone_id = var.cloudflare_zone_id
  name    = "fm3._domainkey"
  content = "fm3.eltimn.com.dkim.fmhosted.com"
  type    = "CNAME"
  ttl     = 1
  proxied = false
  comment = "DKIM record for Fastmail"
}

resource "cloudflare_dns_record" "www" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  content = "${cloudflare_pages_project.eltimn.name}.pages.dev"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

# MX Records
resource "cloudflare_dns_record" "mx_10" {
  zone_id  = var.cloudflare_zone_id
  name     = "@"
  content  = "in1-smtp.messagingengine.com"
  type     = "MX"
  ttl      = 1
  priority = 10
  proxied  = false
  comment  = "Fastmail SMTP server"
}

resource "cloudflare_dns_record" "mx_20" {
  zone_id  = var.cloudflare_zone_id
  name     = "@"
  content  = "in2-smtp.messagingengine.com"
  type     = "MX"
  ttl      = 1
  priority = 20
  proxied  = false
  comment  = "Fastmail SMTP server"
}

# TXT Records
resource "cloudflare_dns_record" "spf" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  content = "v=spf1 include:spf.messagingengine.com ?all"
  type    = "TXT"
  ttl     = 1
  proxied = false
  comment = "SPF record for Fastmail"
}

resource "cloudflare_dns_record" "keybase" {
  zone_id = var.cloudflare_zone_id
  name    = "_keybase"
  content = "keybase-site-verification=Uos6Mn3FUdvZO-KUBGJmzZD_JRFAPzsj9PvWU3Gij80"
  type    = "TXT"
  ttl     = 1
  proxied = false
}
