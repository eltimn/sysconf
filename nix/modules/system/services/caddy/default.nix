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
    virtualHosts = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Virtual host configurations. Each attribute is a subdomain, and the value is the Caddyfile config string.";
      example = lib.literalExpression ''
        {
          forgejo = '''
            reverse_proxy localhost:3000
          ''';
        }
      '';
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

      virtualHosts."*.${cfg.domain}" = {
        extraConfig =
          let
            # Generate virtual host handlers from the virtualHosts option
            generateVirtualHost =
              subdomain: config:
              ''
                @${subdomain} host ${subdomain}.${cfg.domain}
                handle @${subdomain} {
                  ${config}
                }

              '';
            dynamicVirtualHosts = lib.concatStringsSep "" (
              lib.mapAttrsToList generateVirtualHost cfg.virtualHosts
            );
          in
          ''
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }

            @unifi host unifi.${cfg.domain}
            handle @unifi {
              reverse_proxy https://router.${cfg.domain} {
                transport http {
                  tls_insecure_skip_verify # unifi uses self-signed certs
                }
              }
            }

            @jellyfin host jellyfin.${cfg.domain}
            handle @jellyfin {
              reverse_proxy localhost:${toString config.sysconf.services.jellyfin.port}
            }

            @dvr host dvr.${cfg.domain}
            handle @dvr {
              reverse_proxy localhost:${toString config.sysconf.containers.channels-dvr.port}
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

            @pics host pics.${cfg.domain}
            handle @pics {
              reverse_proxy localhost:${toString config.services.immich.port}
            }

            ${dynamicVirtualHosts}
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
