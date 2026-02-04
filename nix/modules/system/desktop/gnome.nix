{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sysconf.desktop.gnome;
in
{
  options.sysconf.desktop.gnome = {
    enable = lib.mkEnableOption "gnome";
    videoDrivers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of video drivers to use for the X server.";
    };
  };

  config = lib.mkIf cfg.enable {
    # X Server configuration
    services = {
      xserver = {
        enable = true;
        xkb = {
          layout = "us";
          variant = "";
        };

        videoDrivers = cfg.videoDrivers;
      };

      # Display Manager and Desktop Environment
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

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
