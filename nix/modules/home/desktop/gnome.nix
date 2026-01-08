{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.gnome;
in
{
  options.sysconf.gnome = {
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
