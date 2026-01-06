# DigitalOcean App Platform - DEPRECATED
# Migrated to Cloudflare Pages (see pages.tf)

locals {
  eltimn_web_alias = "king-prawn-app-3k2ql.ondigitalocean.app"
}

resource "digitalocean_app" "eltimn" {
  spec {
    name   = "king-prawn-app"
    region = "nyc"

    domain {
      name = "eltimn.com"
    }

    domain {
      name = "www.eltimn.com"
    }

    alert {
      rule = "DEPLOYMENT_FAILED"
    }

    alert {
      rule = "DOMAIN_FAILED"
    }

    static_site {
      name             = "eltimn-com"
      source_dir       = "/"
      build_command    = "hugo"
      output_dir       = "public"
      environment_slug = "hugo"

      github {
        repo           = "eltimn/eltimn.com"
        branch         = "main"
        deploy_on_push = true
      }
    }
  }
}
