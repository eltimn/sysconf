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
    # Enable the COSMIC login manager
    services.displayManager.cosmic-greeter.enable = true;

    # Enable the COSMIC desktop environment
    services.desktopManager.cosmic.enable = true;

    environment.cosmic.excludePackages = with pkgs; [
      cosmic-player
      cosmic-store
    ];

    services.system76-scheduler.enable = true;
  };
}
