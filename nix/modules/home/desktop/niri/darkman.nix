{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  cfg = config.sysconf.desktop.niri;

  syncGtkPkg = pkgs.writeShellScriptBin "sync-gtk-theme" ''
    THEME_MODE="$1"

    # check if the theme mode is valid
    if [[ "$THEME_MODE" != "dark" && "$THEME_MODE" != "light" ]]; then
      echo "Invalid theme mode: $THEME_MODE"
      exit 1
    fi

    # make a symlink for gtk3 & gtk4 themes based on the current theme mode
    ln -sf "${config.home.homeDirectory}/.config/darkman/themes/gtk3-$THEME_MODE.css" "${config.home.homeDirectory}/.config/gtk-3.0/gtk.css"
    ln -sf "${config.home.homeDirectory}/.config/darkman/themes/gtk4-$THEME_MODE.css" "${config.home.homeDirectory}/.config/gtk-4.0/gtk.css"
  '';

  syncDconfPkg = pkgs.writeShellScriptBin "sync-dconf-theme" ''
    THEME_MODE="$1"

    # check if the theme mode is valid
    if [[ "$THEME_MODE" != "dark" && "$THEME_MODE" != "light" ]]; then
      echo "Invalid theme mode: $THEME_MODE"
      exit 1
    fi

    # some gtk apps check this dconf key
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-$THEME_MODE'"
  '';

  generateScripts = lib.mapAttrs' (
    k: v: {
      name = "darkman/${k}";
      value = {
        executable = true;
        source =
          if lib.isDerivation v then
            lib.getExe v
          else if builtins.isPath v then
            v
          else
            pkgs.writeShellScript (lib.hm.strings.storeFileName k) v;
      };
    }
  );
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.darkman = {
        enable = true;
        package = pkgs-unstable.darkman;
        settings = {
          usegeoclue = false;
          dbusserver = true;
          portal = true;
        };
      };
    })

    (lib.mkIf (cfg.enable && cfg.enableThemeHandlers) {
      sysconf.desktop.niri.themeHandlers = {
        gtk = syncGtkPkg;
        dconf = syncDconfPkg;
      };

      xdg.configFile = {
        "darkman/themes/gtk3-dark.css".source = ./files/gtk3-dark.css;
        "darkman/themes/gtk3-light.css".source = ./files/gtk3-light.css;
        "darkman/themes/gtk4-dark.css".source = ./files/gtk4-dark.css;
        "darkman/themes/gtk4-light.css".source = ./files/gtk4-light.css;
      };

      xdg.dataFile = lib.mkIf (cfg.themeHandlers != { }) (generateScripts cfg.themeHandlers);
    })
  ];
}
