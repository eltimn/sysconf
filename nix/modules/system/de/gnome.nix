{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sysconf.system.gnome;
in
{
  options.sysconf.system.gnome = {
    videoDrivers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of video drivers to use for the X server.";
    };
  };

  config = {
    # X Server configuration
    services.xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };

      videoDrivers = cfg.videoDrivers;
    };

    # Display Manager and Desktop Environment
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # GNOME Package Exclusions
    environment.gnome.excludePackages = with pkgs; [
      gnome-photos
      gnome-tour
      cheese
      gnome-music
      epiphany
      geary
      evince
      gnome-characters
      totem
      tali
      iagno
      hitori
      atomix
      yelp
      gnome-maps
      gnome-weather
      gnome-contacts
      simple-scan
    ];
  };
}
