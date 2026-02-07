{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.niri;
  greetdEnabled = config.sysconf.desktop.greetd.enable;
in
{
  options.sysconf.desktop.niri = {
    enable = lib.mkEnableOption "niri";
  };

  config = lib.mkIf cfg.enable {
    # Wayland baseline
    services.dbus.enable = true;
    security.polkit.enable = true;

    programs.niri.enable = true;

    # Only enable greetd here if greetd module is not managing sessions
    # (fallback for single-DE setups using just niri)
    services.greetd = lib.mkIf (!greetdEnabled) {
      enable = true;
      settings = {
        default_session = {
          command = "${lib.getExe pkgs.tuigreet} --cmd niri-session";
          user = "greeter";
        };
      };
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
        # Explicitly route theme/setting requests to darkman
        "org.freedesktop.impl.portal.Settings" = [ "darkman" ];
        # Screenshot and screencast
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      };
    };
  };
}
