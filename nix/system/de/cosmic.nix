{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sysconf.system.cosmic;
in
{
  options.sysconf.system.cosmic = {
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

    environment.systemPackages = with pkgs; [
      cosmic-ext-applet-clipboard-manager
    ];

    services.system76-scheduler.enable = true;
  };
}
