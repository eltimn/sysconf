{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.dms;
in
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms-plugin-registry.modules.default
  ];

  options.sysconf.desktop.dms = {
    enable = lib.mkEnableOption "dms";
  };

  config = lib.mkIf cfg.enable {

    home.file = {
      ".config/niri/dms/alttab.kdl".source = ./files/alttab.kdl;
      ".config/niri/dms/binds.kdl".source = ./files/binds.kdl;
      ".config/niri/dms/colors.kdl".source = ./files/colors.kdl;
      ".config/niri/dms/cursor.kdl".source = ./files/cursor.kdl;
      ".config/niri/dms/layout.kdl".source = ./files/layout.kdl;
      ".config/niri/dms/outputs.kdl".source = ./files/outputs.kdl;
      ".config/niri/dms/windowrules.kdl".source = ./files/windowrules.kdl;
      ".config/niri/dms/wpblur.kdl".source = ./files/wpblur.kdl;
    };

    programs.dank-material-shell = {
      enable = true;
      dgop.package = inputs.dgop.packages.${pkgs.system}.default;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      enableSystemMonitoring = true;
      enableVPN = false;
      enableDynamicTheming = false;
      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;

      settings = {
        theme = "dark";
        dynamicTheming = true;
      };

      session = {
        isLightMode = false;
      };

      plugins = {
        # dankBatteryAlerts.enable = true;
        dockerManager.enable = true;
      };
    };
  };
}
