# Policy kit GNOME authentication agent for niri
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.polkit;
in
{
  options.sysconf.desktop.polkit = {
    enable = lib.mkEnableOption "polkit-gnome authentication agent";
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.polkit-authentication-agent = {
      Unit = {
        Description = "Polkit authentication agent";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
      };
      Service = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
