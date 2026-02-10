{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sysconf.desktop.cosmic;
  greetdEnabled = config.sysconf.desktop.greetd.enable;
in
{
  options.sysconf.desktop.cosmic = {
    enable = lib.mkEnableOption "cosmic";
  };

  config = lib.mkIf cfg.enable {
    services = {
      # Only enable cosmic-greeter if greetd is not managing sessions
      displayManager.cosmic-greeter.enable = !greetdEnabled;

      # Enable the COSMIC desktop environment
      desktopManager.cosmic.enable = true;

      system76-scheduler.enable = true;
    };

    environment.cosmic.excludePackages = with pkgs; [
      cosmic-player
      cosmic-store
    ];
  };
}
