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
    # Wayland baseline
    services.dbus.enable = true;
    security.polkit.enable = true;

    programs.niri.enable = true;

    # Simple, reliable login for wlroots compositors.
    services.greetd = {
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
      ];
    };
  };
}
