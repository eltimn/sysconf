{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.services.incus;
  settings = config.sysconf.settings;
in
{
  options.sysconf.services.incus = {
    enable = lib.mkEnableOption "Incus container manager";

    storagePath = lib.mkOption {
      type = lib.types.str;
      default = "/srv/main/incus";
      description = "Path to the Btrfs subvolume for Incus storage.";
    };

    parentInterface = lib.mkOption {
      type = lib.types.str;
      default = "br0";
      description = "Parent network interface for the Incus bridge.";
    };

    bindAddress = lib.mkOption {
      type = lib.types.str;
      description = "The network address to bind to.";
      default = "0.0.0.0";
    };

    oidcClientIdFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to the file containing the OIDC Client ID for Pocket ID integration.";
    };

    adminUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Users to add to the incus-admin group.";
      default = [ ];
    };

  };

  config = lib.mkIf cfg.enable {
    virtualisation.incus = {
      enable = true;
      ui.enable = true;

      preseed = {
        config = {
          "core.https_address" = "${cfg.bindAddress}:8443";
          "oidc.issuer" = "https://id.${settings.homeDomain}";
          "oidc.scopes" = "openid,email,profile";
        };

        storage_pools = [
          {
            name = "default";
            driver = "btrfs";
            config = {
              source = cfg.storagePath;
            };
          }
        ];

        profiles = [
          {
            name = "default";
            devices = {
              root = {
                path = "/";
                pool = "default";
                type = "disk";
              };
              eth0 = {
                name = "eth0";
                nictype = "bridged";
                parent = cfg.parentInterface;
                type = "nic";
              };
            };
          }
        ];
      };
    };

    systemd.services.incus.postStart = lib.mkAfter ''
      oidc_file='${cfg.oidcClientIdFile}'

      if [ -r "$oidc_file" ]; then
        client_id="$(${pkgs.coreutils}/bin/cat "$oidc_file")"
        client_id="''${client_id//$'\n'/}"
        client_id="''${client_id//$'\r'/}"

        if [ -n "$client_id" ]; then
          export INCUS_DIR=/var/lib/incus
          ${pkgs.incus}/bin/incus config set oidc.client.id "$client_id" || true
          ${pkgs.incus}/bin/incus config set oidc.audience "$client_id" || true
        fi
      fi
    '';

    # Ensure the required kernel modules for bridge networking are loaded if not already
    boot.kernelModules = [ "bridge" ];

    # Enable IP forwarding for container networking
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    # Add configured admin users to the incus-admin group
    users.users = lib.genAttrs cfg.adminUsers (user: {
      extraGroups = lib.mkAfter [ "incus-admin" ];
    });

    networking = {
      # Incus on NixOS requires nftables
      nftables.enable = true;
      # Open the Incus API port in the firewall
      firewall.allowedTCPPorts = [ 8443 ];
    };

    # Caddy reverse proxy for Incus UI
    services.caddy.virtualHosts."incus.${settings.homeDomain}".extraConfig = ''
      reverse_proxy https://localhost:8443 {
        header_up Host {host}
        transport http {
          tls_insecure_skip_verify
        }
      }
      tls {
        dns cloudflare {env.CF_API_TOKEN}
      }
    '';
  };
}
