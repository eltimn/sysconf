{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sysconf.desktop.cosmic;
in
{
  options.sysconf.desktop.cosmic = {
    enable = lib.mkEnableOption "cosmic";
  };

  config = lib.mkIf cfg.enable {
    services = {
      # Enable the COSMIC login manager
      displayManager.cosmic-greeter.enable = true;

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
