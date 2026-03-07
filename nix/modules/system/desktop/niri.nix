{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.niri;
in
{
  options.sysconf.desktop.niri = {
    enable = lib.mkEnableOption "niri";
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    security.polkit.enable = true; # Wayland baseline

    services = {
      dbus.enable = true; # Wayland baseline
      # USB drive auto-mounting support
      udisks2.enable = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
        darkman
      ];
      config.common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [ "darkman" ];
      };
      config.niri = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [ "darkman" ];
        # Screenshot and screencast
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      };
    };
  };
}
