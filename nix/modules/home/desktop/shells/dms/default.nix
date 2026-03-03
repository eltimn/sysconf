{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.dms;
  isLaptop = osConfig.sysconf.settings.isBatteryPowered;
  niriCfg = config.sysconf.desktop.niri;
  wallpaperPath = "${config.home.homeDirectory}/Downloads/047.jpg";

  minToSec = n: n * 60;
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

        # power mgmt
        acMonitorTimeout = minToSec niriCfg.monitorOffTimeout;
        acLockTimeout = minToSec niriCfg.lockTimeout;
        acSuspendTimeout = minToSec niriCfg.suspendTimeout;
        acSuspendBehavior = 0;
        acProfileName = "";
        batteryMonitorTimeout = minToSec niriCfg.monitorOffTimeout;
        batteryLockTimeout = minToSec niriCfg.lockTimeout;
        batterySuspendTimeout = minToSec niriCfg.suspendTimeout;
        batterySuspendBehavior = 0;
        batteryProfileName = "";
        lockBeforeSuspend = isLaptop;

        # theme syncing
        gtkThemingEnabled = false;
        qtThemingEnabled = false;
        syncModeWithPortal = false;
        terminalsAlwaysDark = false;
        runDmsMatugenTemplates = false;
        runUserMatugenTemplates = false;
        matugenTemplateGtk = false;
        matugenTemplateNiri = false;
        matugenTemplateHyprland = false;
        matugenTemplateMangowc = false;
        matugenTemplateQt5ct = false;
        matugenTemplateQt6ct = false;
        matugenTemplateFirefox = false;
        matugenTemplatePywalfox = false;
        matugenTemplateZenBrowser = false;
        matugenTemplateVesktop = false;
        matugenTemplateEquibop = false;
        matugenTemplateGhostty = false;
        matugenTemplateKitty = false;
        matugenTemplateFoot = false;
        matugenTemplateAlacritty = false;
        matugenTemplateNeovim = false;
        matugenTemplateWezterm = false;
        matugenTemplateDgop = false;
        matugenTemplateKcolorscheme = false;
        matugenTemplateVscode = false;
        matugenTemplateEmacs = false;
      };

      session = {
        inherit wallpaperPath;
        themeModeAutoEnabled = false;
        # themeModeAutoMode = "time";
        # themeModeStartHour = 19;
        # themeModeStartMinute = 0;
        # themeModeEndHour = 6;
        # themeModeEndMinute = 30;
        weatherLocation = "Minneapolis, Minnesota";
        weatherCoordinates = "44.9772995,-93.2654692";
      };

      plugins = {
        dankBatteryAlerts.enable = isLaptop;
        dockerManager.enable = true;
      };
    };
  };
}
