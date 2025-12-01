{ config, lib, ... }:
let
  cfg = config.eltimn.services.jellyfin;
in
{
  options.eltimn.services.jellyfin = {
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

    # Bind Jellyfin to isolated subnet IP
    # environment.etc."jellyfin/network.json".text = builtins.toJSON {
    #   host = "192.168.20.115";
    #   port = 8096;
    #   protocol = "http";
    # };
  };
}
