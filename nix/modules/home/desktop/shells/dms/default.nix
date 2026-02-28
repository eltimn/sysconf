{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.dms;
  wallpaperPath = "${config.home.homeDirectory}/Downloads/047.jpg";
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
      ".config/niri/dms/wpblur.kdl".source = ./files/wpblur.kdl;
      ".config/DankMaterialShell/tokyo-night.json".source = ./files/tokyo-night.json;
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
        currentThemeName = "custom";
        customThemeFile = "${config.home.homeDirectory}/.config/DankMaterialShell/tokyo-night.json";
        launcherLogoMode = "os";
        barConfigs = builtins.fromJSON (builtins.readFile ./files/barConfigs.json);
        use24HourClock = false;
        useFahrenheit = true;
        acMonitorTimeout = 600;
        acLockTimeout = 0;
        acSuspendTimeout = 1800;
        acSuspendBehavior = 0;
        acProfileName = "";
        lockBeforeSuspend = false;
      };

      session = {
        inherit wallpaperPath;
        isLightMode = false;
        themeModeAutoEnabled = true;
        themeModeAutoMode = "time";
        themeModeStartHour = 19;
        themeModeStartMinute = 0;
        themeModeEndHour = 6;
        themeModeEndMinute = 30;
        weatherLocation = "Minneapolis, Minnesota";
        weatherCoordinates = "44.9772995,-93.2654692";
      };

      plugins = {
        # dankBatteryAlerts.enable = true;
        dockerManager.enable = true;
      };
    };
  };
}
