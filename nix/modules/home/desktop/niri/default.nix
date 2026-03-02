{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.niri;
in
{
  options.sysconf.desktop.niri = {
    enable = lib.mkEnableOption "niri";

    lockTimeout = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = "Timeout in minutes before locking the screen. If 0, screen locking is disabled.";
    };

    monitorOffTimeout = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = "Timeout in minutes before turning off monitors. If 0, monitor power-off is disabled.";
    };

    suspendTimeout = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = ''
        Timeout in minutes before suspending the system.

        Suspend (sleep) saves your session to RAM and enters a low-power state.
        The system wakes quickly but continues to use some battery power.

        Note: Hibernate (not implemented here) saves to disk and powers off completely,
        using no battery but taking longer to resume. Hibernate requires swap space
        configuration at the system level.

        If 0, automatic suspend is disabled.
      '';
    };

    isLaptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this is a laptop. If true, battery monitoring and alerts will be enabled.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.str;
      description = "Extra config to add to Niri";
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        niri
        wl-clipboard
        xwayland-satellite
      ];

      pointerCursor = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };

      file = {
        ".config/niri/config.kdl".text = ''
          include "./main.kdl"
          include "./binds.kdl"
          include "./extra.kdl"
          ${lib.optionalString (osConfig.sysconf.settings.niriShell == "noctalia") ''
            include "./noctalia/config.kdl"
            include "./noctalia.kdl"
          ''}
          ${lib.optionalString (osConfig.sysconf.settings.niriShell == "dms") ''
            include "./dms/alttab.kdl"
            include "./dms/binds.kdl"
            include "./dms/wpblur.kdl"
          ''}
        '';

        ".config/niri/main.kdl".source = ./files/main.kdl;
        ".config/niri/binds.kdl".source = ./files/binds.kdl;
        ".config/niri/extra.kdl".text = cfg.extraConfig;
      };
    };
  };
}

# niri regex: https://docs.rs/regex/latest/regex/#syntax
