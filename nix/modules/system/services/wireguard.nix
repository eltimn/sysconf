{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.services.wireguard;
in
{
  options.sysconf.services.wireguard = {
    enable = lib.mkEnableOption "WireGuard VPN client";

    interface = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
      description = "WireGuard interface name";
    };

    address = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "WireGuard IP addresses";
    };

    dns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "DNS servers to use";
    };

    serverPublicKey = lib.mkOption {
      type = lib.types.str;
      description = "WireGuard server public key";
    };

    endpoint = lib.mkOption {
      type = lib.types.str;
      description = "WireGuard server endpoint (host:port)";
    };

    allowedIPs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "0.0.0.0/0" ];
      description = "Allowed IPs for routing";
    };

    persistentKeepalive = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = 25;
      description = "Persistent keepalive interval in seconds (useful for laptops behind NAT)";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.wg-quick.interfaces.${cfg.interface} = {
      address = cfg.address;
      dns = cfg.dns;
      privateKeyFile = config.sops.secrets."wireguard/${config.networking.hostName}/private_key".path;

      peers = [
        {
          publicKey = cfg.serverPublicKey;
          allowedIPs = cfg.allowedIPs;
          endpoint = cfg.endpoint;
          persistentKeepalive = cfg.persistentKeepalive;
        }
      ];
    };

    sops.secrets."wireguard/${config.networking.hostName}/private_key" = { };
  };
}
