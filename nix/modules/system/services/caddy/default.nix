{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.services.caddy;
  settings = config.sysconf.settings;
in
{
  options.sysconf.services.caddy = {
    enable = lib.mkEnableOption "caddy";
    domain = lib.mkOption {
      type = lib.types.str;
      default = settings.homeDomain;
      description = "The domain used for caddy.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2" ];
        hash = "sha256-dnhEjopeA0UiI+XVYHYpsjcEI6Y1Hacbi28hVKYQURg=";
      };
      environmentFile = "/run/keys/caddy-env";

      # config settings
      # https://caddyserver.com/docs/caddyfile/patterns#wildcard-certificates
      # acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory";
      email = "{env.CF_EMAIL}";

      virtualHosts."*.${cfg.domain}".extraConfig = ''
        tls {
          dns cloudflare {env.CF_API_TOKEN}
        }

        # Fallback for otherwise unhandled domains
        handle {
          abort
        }
      '';

      virtualHosts."unifi.${cfg.domain}".extraConfig = ''
        reverse_proxy https://router.${cfg.domain} {
          transport http {
            tls_insecure_skip_verify # unifi uses self-signed certs
          }
        }
      '';
    };

    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
