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

  minutes = n: n * 60;
in
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms-plugin-registry.modules.default
  ];

  options.sysconf.desktop.dms = {
    enable = lib.mkEnableOption "dms";

    isLaptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this is a laptop. If true, battery monitoring and alerts will be enabled.";
    };
  };

  config = lib.mkIf cfg.enable {

    home.file = {
      ".config/niri/dms/alttab.kdl".source = ./files/niri/alttab.kdl;
      ".config/niri/dms/binds.kdl".source = ./files/niri/binds.kdl;
      ".config/niri/dms/colors.kdl".source = ./files/niri/colors.kdl;
      ".config/niri/dms/wpblur.kdl".source = ./files/niri/wpblur.kdl;
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
      enableDynamicTheming = true;
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
        acMonitorTimeout = minutes 10;
        acLockTimeout = if cfg.isLaptop then minutes 15 else 0;
        acSuspendTimeout = minutes 30;
        acSuspendBehavior = 0;
        acProfileName = "";
        lockBeforeSuspend = cfg.isLaptop;
      };

      session = {
        inherit wallpaperPath;
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
        dankBatteryAlerts.enable = cfg.isLaptop;
        dockerManager.enable = true;
      };
    };
  };
}
