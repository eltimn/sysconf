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
    name = "Nordic";
    package = pkgs.nordic;
  };

  # gtkSettings = ''
  #   [Settings]
  #   gtk-cursor-theme-name=Adwaita
  #   gtk-cursor-theme-size=24
  #   gtk-icon-theme-name=Adwaita
  #   gtk-theme-name=${theme.name}
  # '';

  syncGtkScript = pkgs.writeShellScriptBin "sync-gtk-theme" ''
    THEME_MODE="$1"

    # check if the theme mode is valid
    if [[ "$THEME_MODE" != "dark" && "$THEME_MODE" != "light" ]]; then
      echo "Invalid theme mode: $THEME_MODE"
      exit 1
    fi

    # make symlinks for the gtk css files
    # if [[ "$THEME_MODE" == "dark" ]]; then
    #   ln -sf ${pkgs.tokyonight-gtk-theme}/share/themes/Tokyonight-Dark/gtk-4.0/assets "${config.home.homeDirectory}/.config/gtk-4.0/assets"
    #   ln -sf ${pkgs.tokyonight-gtk-theme}/share/themes/Tokyonight-Dark/gtk-4.0/gtk.css "${config.home.homeDirectory}/.config/gtk-4.0/gtk.css"
    #   ln -sf ${pkgs.tokyonight-gtk-theme}/share/themes/Tokyonight-Dark/gtk-3.0/assets "${config.home.homeDirectory}/.config/gtk-3.0/assets"
    #   ln -sf ${pkgs.tokyonight-gtk-theme}/share/themes/Tokyonight-Dark/gtk-3.0/gtk.css "${config.home.homeDirectory}/.config/gtk-3.0/gtk.css"
    # else
    #   ln -sf ${pkgs.tokyonight-gtk-theme}/share/themes/Tokyonight-Light/gtk-4.0/assets "${config.home.homeDirectory}/.config/gtk-4.0/assets"
    #   ln -sf ${pkgs.tokyonight-gtk-theme}/share/themes/Tokyonight-Light/gtk-4.0/gtk.css "${config.home.homeDirectory}/.config/gtk-4.0/gtk.css"
    #   ln -sf ${pkgs.tokyonight-gtk-theme}/share/themes/Tokyonight-Light/gtk-3.0/assets "${config.home.homeDirectory}/.config/gtk-3.0/assets"
    #   ln -sf ${pkgs.tokyonight-gtk-theme}/share/themes/Tokyonight-Light/gtk-3.0/gtk.css "${config.home.homeDirectory}/.config/gtk-3.0/gtk.css"
    # fi

    # if [[ "$THEME_MODE" == "dark" ]]; then
    #   echo "@import url(\"file://${theme.package}/share/themes/${theme.name}/gtk-4.0/gtk-dark.css\");" > "${config.home.homeDirectory}/.config/gtk-4.0/gtk.css"
    #   echo "@import url(\"file://${theme.package}/share/themes/${theme.name}/gtk-3.0/gtk-dark.css\");" > "${config.home.homeDirectory}/.config/gtk-3.0/gtk.css"
    # else
    #   echo "@import url(\"file://${theme.package}/share/themes/${theme.name}/gtk-4.0/gtk.css\");" > "${config.home.homeDirectory}/.config/gtk-4.0/gtk.css"
    #   echo "@import url(\"file://${theme.package}/share/themes/${theme.name}/gtk-3.0/gtk.css\");" > "${config.home.homeDirectory}/.config/gtk-3.0/gtk.css"
    # fi

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
      # home.packages = [ pkgs.tokyonight-gtk-theme ];
      home.packages = [
        pkgs.adwaita-icon-theme
        theme.package
      ];
      gtk = {
        inherit theme;
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

      # xdg.configFile = {
      #   "gtk-3.0/settings.ini".text = gtkSettings;
      #   "gtk-4.0/settings.ini".text = gtkSettings;
      # };
    })

    (lib.mkIf (cfg.enable && cfg.enableThemeHandlers) {
      sysconf.desktop.themeHandlers.gtk = syncGtkScript;
      xdg.dataFile = generateScripts config.sysconf.desktop.themeHandlers;
    })
  ];
}
