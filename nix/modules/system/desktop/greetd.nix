{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.greetd;
  # Standard wayland-sessions path that packages install to
  sessionsPath = "/run/current-system/sw/share/wayland-sessions";
in
{
  options.sysconf.desktop.greetd = {
    enable = lib.mkEnableOption "greetd with tuigreet session selection";
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      # Required for TUI greeters to display properly
      useTextGreeter = true;
      settings = {
        default_session = {
          command = lib.concatStringsSep " " [
            (lib.getExe pkgs.tuigreet)
            "--sessions ${sessionsPath}"
            "--remember"
            "--remember-session"
            "--time"
            "--asterisks"
          ];
          user = "greeter";
        };
      };
    };

    # Ensure session desktop files are available in the sessions path
    # by linking relevant packages to the system profile
    environment.pathsToLink = [ "/share/wayland-sessions" ];
  };
}
