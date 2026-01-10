# Channels DVR container using the rootless container module
#
# Managing the service:
#   machinectl shell channelsdvr@ /run/current-system/sw/bin/bash
#   systemctl --user status channels-dvr
#   journalctl --user -eu channels-dvr
# Or:
#   sudo -u channelsdvr XDG_RUNTIME_DIR=/run/user/989 systemctl --user status channels-dvr
#   sudo -u channelsdvr XDG_RUNTIME_DIR=/run/user/989 journalctl --user -eu channels-dvr
{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.containers.channels-dvr;
  settings = config.sysconf.settings;
in
{
  options.sysconf.containers.channels-dvr = {
    enable = lib.mkEnableOption "channels-dvr";
    port = lib.mkOption {
      type = lib.types.port;
      description = "The port Channels DVR runs on.";
      default = 8089; # Has no effect
    };
  };

  config = lib.mkIf cfg.enable {
    sysconf.rootlessContainers = {
      enable = true;

      users.channelsdvr = {
        uid = 989;
        group = "users";
        createGroup = false;

        containers.channels-dvr = {
          description = "Channels DVR Container";
          image = "docker.io/fancybits/channels-dvr@sha256:52a8ed8d2071f01dbb30932b8e8d28b2b507289c2fde6f00f43779f657b5ed82";
          network = "host";
          devices = [ "/dev/dri:/dev/dri" ];
          volumes = [
            "/var/lib/channelsdvr/storage:/channels-dvr"
            "/mnt/channels:/shares/DVR"
          ];
        };
      };
    };

    # Firewall rules for Channels DVR
    networking.firewall.allowedTCPPorts = [
      cfg.port # channels-dvr web interface
      5353 # channels-dvr Bonjour/mDNS
    ];
    networking.firewall.allowedUDPPorts = [
      5353 # channels-dvr Bonjour/mDNS
    ];

    # Storage directory
    systemd.tmpfiles.rules = [
      "d /var/lib/channelsdvr/storage 0770 channelsdvr users -"
    ];

    services.caddy.virtualHosts."dvr.${settings.homeDomain}".extraConfig = ''
      reverse_proxy localhost:${toString cfg.port}
      tls { dns cloudflare {env.CF_API_TOKEN} }
    '';
  };
}
