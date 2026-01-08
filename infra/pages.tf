# Cloudflare Pages
# https://search.opentofu.org/provider/cloudflare/cloudflare/latest/docs/resources/pages_project

resource "cloudflare_pages_project" "eltimn" {
  account_id        = var.cloudflare_account_id
  name              = "eltimn-com"
  production_branch = "main"

  # TODO: Is this and deployment_configs necessary since we deploy from github?
  build_config = {
    build_command   = "hugo"
    destination_dir = "public"
    root_dir        = "/"
  }

  deployment_configs = {
    production = {
      compatibility_date = "2024-01-01"
      env_vars = {
        HUGO_VERSION = {
          type  = "plain_text"
          value = "0.139.0"
        }
      }
    }
    preview = {
      compatibility_date = "2024-01-01"
      env_vars = {
        HUGO_VERSION = {
          type  = "plain_text"
          value = "0.139.0"
        }
      }
    }
  }
}

# Custom domain for the Pages project
resource "cloudflare_pages_domain" "eltimn_root" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.eltimn.name
  name         = "eltimn.com"
}

resource "cloudflare_pages_domain" "eltimn_www" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.eltimn.name
  name         = "www.eltimn.com"
}
