{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  cfg = config.sysconf.desktop.niri;
  theme = {
    name = "Tokyonight";
    package = pkgs.tokyonight-gtk-theme;
  };

  syncGtkScript = pkgs.writeShellScriptBin "sync-gtk-theme" ''
    THEME_MODE="$1"

    # check if the theme mode is valid
    if [[ "$THEME_MODE" != "dark" && "$THEME_MODE" != "light" ]]; then
      echo "Invalid theme mode: $THEME_MODE"
      exit 1
    fi

    # make a symlink for gtk3 & gtk4 themes based on the current theme mode
    # mkdir -p "${config.home.homeDirectory}/.config/gtk-3.0"
    # mkdir -p "${config.home.homeDirectory}/.config/gtk-4.0"
    # ln -sf "${config.home.homeDirectory}/.config/darkman/themes/gtk3-$THEME_MODE.css" "${config.home.homeDirectory}/.config/gtk-3.0/gtk.css"
    # ln -sf "${config.home.homeDirectory}/.config/darkman/themes/gtk4-$THEME_MODE.css" "${config.home.homeDirectory}/.config/gtk-4.0/gtk.css"

    # make symlinks for the gtk css files
    if [[ "$THEME_MODE" == "dark" ]]; then
      ln -sf ${pkgs.tokyonight-gtk-theme}/share/themes/Tokyonight-Dark/gtk-4.0/gtk-dark.css "${config.home.homeDirectory}/.config/gtk-4.0/gtk.css"
      ln -sf ${pkgs.tokyonight-gtk-theme}/share/themes/Tokyonight-Dark/gtk-3.0/gtk-dark.css "${config.home.homeDirectory}/.config/gtk-3.0/gtk.css"
    else
      ln -sf ${pkgs.tokyonight-gtk-theme}/share/themes/Tokyonight-Light/gtk-4.0/gtk.css "${config.home.homeDirectory}/.config/gtk-4.0/gtk.css"
      ln -sf ${pkgs.tokyonight-gtk-theme}/share/themes/Tokyonight-Light/gtk-3.0/gtk.css "${config.home.homeDirectory}/.config/gtk-3.0/gtk.css"
    fi


    # set the dconf key
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-$THEME_MODE'"

    # restart the portal
    systemctl --user restart xdg-desktop-portal-gtk
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
      home.packages = [ theme.package ];
      gtk = {
        enable = true;
        iconTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };
        cursorTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
          size = 24;
        };
      };
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
      sysconf.desktop.niri.themeHandlers.gtk = syncGtkScript;

      # xdg.configFile = {
      #   "darkman/themes/gtk3-dark.css".source = ./files/gtk3-dark.css;
      #   "darkman/themes/gtk3-light.css".source = ./files/gtk3-light.css;
      #   "darkman/themes/gtk4-dark.css".source = ./files/gtk4-dark.css;
      #   "darkman/themes/gtk4-light.css".source = ./files/gtk4-light.css;
      # };

      xdg.dataFile = lib.mkIf (cfg.themeHandlers != { }) (generateScripts cfg.themeHandlers);
    })
  ];
}
