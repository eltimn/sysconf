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
  port = 8089; # Currently, Channels DVR doesn't have a way to set the port. I believe the client also expects to use 8089 even though I use https.
  storageDir = "/var/lib/channelsdvr/storage";
  pathToUnitName = path: lib.removePrefix "-" (lib.strings.escapeSystemdPath path);
in
{
  options.sysconf.containers.channels-dvr = {
    enable = lib.mkEnableOption "channels-dvr";
    dvrDir = lib.mkOption {
      type = lib.types.str;
      description = "The location of the DVR directory.";
      default = "/mnt/channels";
    };
  };

  config = lib.mkIf cfg.enable {
    sysconf.rootlessContainers = {
      enable = true;

      users."channelsdvr" = {
        uid = 989;
        group = "users";
        createGroup = false;

        containers."channels-dvr" = {
          description = "Channels DVR Container";
          image = "docker.io/fancybits/channels-dvr@sha256:52a8ed8d2071f01dbb30932b8e8d28b2b507289c2fde6f00f43779f657b5ed82";
          network = "host";
          devices = [ "/dev/dri:/dev/dri" ];
          volumes = [
            "${storageDir}:/channels-dvr"
            "${cfg.dvrDir}:/shares/DVR"
          ];
          unitConfig = ''
            After=${pathToUnitName cfg.dvrDir}.mount
            Requires=${pathToUnitName cfg.dvrDir}.mount
          '';
        };
      };
    };

    # Firewall rules for Channels DVR
    networking.firewall.allowedTCPPorts = [
      port # channels-dvr web interface
      5353 # channels-dvr Bonjour/mDNS
    ];
    networking.firewall.allowedUDPPorts = [
      5353 # channels-dvr Bonjour/mDNS
    ];

    # Storage directory
    systemd.tmpfiles.rules = [
      "d ${storageDir} 0770 channelsdvr users -"
    ];

    services.caddy.virtualHosts."dvr.${settings.homeDomain}".extraConfig = ''
      reverse_proxy localhost:${toString port}
      tls { dns cloudflare {env.CF_API_TOKEN} }
    '';
  };
}
