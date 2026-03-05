{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (osConfig.sysconf) settings;
  cfg = config.sysconf.desktop.niri;
in
{
  imports = [
    ./darkman.nix
  ];

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

    extraConfig = lib.mkOption {
      type = lib.types.str;
      description = "Extra config to add to Niri";
      default = "";
    };

    # Scripts are passed the current theme mode as an argument (e.g. 'dark' or 'light').
    themeHandlers = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.path
          lib.types.package
          lib.types.lines
        ]
      );
      default = { };
      description = ''
        An attribute set of custom handlers for darkman. The key is the name of the handler, and the value is either an absolute path to a script or a string containing the script content.
      '';
    };

    enableThemeHandlers = lib.mkOption {
      type = lib.types.bool;
      default = settings.niriShell != "noctalia";
      description = "Whether to enable theme synchronization with darkman.";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        niri
        wl-clipboard
        xwayland-satellite
      ];

      # pointerCursor = {
      #   package = pkgs.adwaita-icon-theme;
      #   name = "Adwaita";
      #   size = 24;
      #   gtk.enable = true;
      #   x11.enable = true;
      # };
    };

    xdg.configFile = {
      "niri/config.kdl".text = ''
        include "./main.kdl"
        include "./binds.kdl"
        include "./extra.kdl"
        ${lib.optionalString (settings.niriShell == "noctalia") ''
          include "./noctalia/config.kdl"
          include "./noctalia.kdl"
        ''}
        ${lib.optionalString (settings.niriShell == "dms") ''
          include "./dms/alttab.kdl"
          include "./dms/binds.kdl"
          include "./dms/wpblur.kdl"
        ''}
      '';

      "niri/main.kdl".source = ./files/main.kdl;
      "niri/binds.kdl".source = ./files/binds.kdl;
      "niri/extra.kdl".text = cfg.extraConfig;
    };
  };
}

# niri regex: https://docs.rs/regex/latest/regex/#syntax
