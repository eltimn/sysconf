{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
let
  cfg = config.eltimn.services.caddy;
in
{
  options.eltimn.services.caddy = {
    enable = lib.mkEnableOption "caddy";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "home.eltimn.com";
      description = "The domain used for caddy.";
    };
  };

  config = lib.mkIf cfg.enable {
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
      # acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory";
      email = "{env.CF_EMAIL}";
      globalConfig = ''
        				acme_dns cloudflare {env.CF_API_TOKEN}
        			'';

      virtualHosts."*.${cfg.domain}" = {
        extraConfig = ''
          					@jellyfin host jellyfin.${cfg.domain}
          					handle @jellyfin {
          						reverse_proxy localhost:${toString config.eltimn.services.jellyfin.port}
          					}

          					@ntfy host ntfy.${cfg.domain}
          					handle @ntfy {
          						reverse_proxy localhost:${toString config.eltimn.services.ntfy.port}
          						@httpget {
          							protocol http
          							method GET
          							path_regexp ^/([-_a-z0-9]{0,64}$|docs/|static/)
          						}
          						redir @httpget https://{host}{uri}
          					}

          					# Fallback for otherwise unhandled domains
          					handle {
          						abort
          					}
          				'';
      };
    };

    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
