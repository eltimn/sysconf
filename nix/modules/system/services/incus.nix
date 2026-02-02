{
  config,
  lib,
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

    bindAdress = lib.mkOption {
      type = lib.types.str;
      description = "The network address to bind to.";
      default = "0.0.0.0";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.incus = {
      enable = true;
      ui.enable = true;

      preseed = {
        config = {
          "core.https_address" = "${cfg.bindAdress}:8443";
          "oidc.audience" = "6a13c9d4-3eb3-4f42-8e7d-69f5b8faf50a";
          "oidc.client.id" = "6a13c9d4-3eb3-4f42-8e7d-69f5b8faf50a";
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

    # Ensure the required kernel modules for bridge networking are loaded if not already
    boot.kernelModules = [ "bridge" ];

    # Enable IP forwarding for container networking
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    # Add the user to the incus-admin group
    users.users.nelly.extraGroups = [ "incus-admin" ];

    # Incus on NixOS requires nftables
    networking.nftables.enable = true;

    # Open the Incus API port in the firewall
    networking.firewall.allowedTCPPorts = [ 8443 ];

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
