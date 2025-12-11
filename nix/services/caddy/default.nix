{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.services.caddy;
in
{
  options.sysconf.services.caddy = {
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
      sopsFile = "${config.eltimn.system.sops.secretsPath}/caddy-enc.env";
      format = "dotenv";
      key = ""; # get the whole file
    };

    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2" ];
        hash = "sha256-ea8PC/+SlPRdEVVF/I3c1CBprlVp1nrumKM5cMwJJ3U=";
      };
      environmentFile = config.sops.secrets.caddy_env.path;

      # config settings
      # https://caddyserver.com/docs/caddyfile/patterns#wildcard-certificates
      # acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory";
      email = "{env.CF_EMAIL}";

      virtualHosts."*.${cfg.domain}" = {
        extraConfig = ''
          tls {
            dns cloudflare {env.CF_API_TOKEN}
          }

          @unifi host unifi.${cfg.domain}
          handle @unifi {
            reverse_proxy https://router.${cfg.domain} {
              transport http {
                tls_insecure_skip_verify # uses self-signed certs
              }
            }
          }

          @jellyfin host jellyfin.${cfg.domain}
          handle @jellyfin {
            reverse_proxy localhost:${toString config.sysconf.services.jellyfin.port}
          }

          @ntfy host ntfy.${cfg.domain}
          handle @ntfy {
            reverse_proxy localhost:${toString config.sysconf.services.ntfy.port}
            @httpget {
              protocol http
              method GET
              path_regexp ^/([-_a-z0-9]{0,64}$|docs/|static/)
            }
            redir @httpget https://{host}{uri}
          }

          @cloud host cloud.${cfg.domain}
          handle @cloud {
            reverse_proxy https://localhost:${toString config.sysconf.services.opencloud.port} {
              transport http {
                tls_insecure_skip_verify # uses self-signed certs
              }
            }

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
