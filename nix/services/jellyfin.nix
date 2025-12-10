{ config, lib, ... }:
let
  cfg = config.sysconf.services.jellyfin;
in
{
  options.sysconf.services.jellyfin = {
    enable = lib.mkEnableOption "jellyfin";
    port = lib.mkOption {
      type = lib.types.int;
      default = 8096; # there doesn't appear to be any way to actually set this port in jellyfin nixos module
      description = "The port number for the jellyfin service.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      openFirewall = false;
    };

    # Set jellyfin to listen on localhost only
    # This didn't work when I tried it.
    # environment.etc."jellyfin/network.json".text = builtins.toJSON {
    #   host = "localhost";
    #   port = cfg.port;
    #   protocol = "http";
    # };
  };
}

# Manual settings
# Guide data provider: https://www.xmltvlistings.com/xmltv/download/VU3PEWZMXJ/10125
# M3U tuner example: https://iptv-org.github.io/iptv/categories/outdoor.m3u
