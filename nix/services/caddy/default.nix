{
  config,
  pkgs,
  vars,
  ...
}:
let
  caddyfileVars = {
    domain = "home.eltimn.com";
    caddy = {
      address = "localhost:2019";
    };

    jellyfin = {
      address = "localhost:8096";
    };
  };
in
{
  sops.secrets."caddy_env" = {
    owner = "caddy";
    reloadUnits = [ "caddy.service" ];
    sopsFile = "${vars.secrets_path}/caddy-enc.env";
    format = "dotenv";
    key = ""; # get the whole file
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2" ];
      hash = "sha256-Z8nPh4OI3/R1nn667ZC5VgE+Q9vDenaQ3QPKxmqPNkc=";
    };
    environmentFile = config.sops.secrets.caddy_env.path;

    # config settings
    # https://caddyserver.com/docs/caddyfile/patterns#wildcard-certificates
    acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory";
    email = "{env.CF_EMAIL}";
    globalConfig = ''
      acme_dns cloudflare {env.CF_API_TOKEN}
    '';

    virtualHosts."*.${caddyfileVars.domain}" = {
      extraConfig = ''
        				@jellyfin host jellyfin.${caddyfileVars.domain}
        				handle @jellyfin {
        					reverse_proxy ${caddyfileVars.jellyfin.address}
        				}

        				@caddy host caddy.${caddyfileVars.domain}
        				handle @caddy {
        					reverse_proxy ${caddyfileVars.caddy.address}
        				}

        				# Fallback for otherwise unhandled domains
        				handle {
        					abort
        				}
        			'';
    };
  };
}
