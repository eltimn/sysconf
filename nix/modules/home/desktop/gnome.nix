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
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        gnome-terminal # needed to run mount-secret on log in
        gnome-tweaks
        gnomeExtensions.appindicator
        gnomeExtensions.clipboard-indicator
        gnomeExtensions.dash-to-dock
      ];
    };
  };
}

## gnome
# - tweak gnome settings
#   - mouse - right click is primary
#   - sound
#   - power mode -> performance for desktops
#   - power saving -> blank screen/suspend
#   - appearance - background
#   - privacy and security - screen lock
# - enable extensions
#   - app indicator
# 	- clipboard indicator
# 	- dash to dock
# 	- system monitor
# 	- user themes
