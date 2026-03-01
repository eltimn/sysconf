{
  config,
  lib,
  osConfig,
  ...
}:
let
  settings = osConfig.sysconf.settings;
in
{
  imports = [
    ./cosmic
    ./niri
    ./shells/dms
    ./shells/noctalia
    ./gnome.nix
  ];

  config = lib.mkMerge [
    {
      home.file."background-image".source = ./lightning-wallpaper;
      home.file."eightbit-me.png".source = ./eightbit-me.png;
    }
    (lib.mkIf (settings.desktopEnvironment == "gnome") {
      sysconf.desktop.gnome.enable = true;
    })
    (lib.mkIf (settings.desktopEnvironment == "cosmic") {
      sysconf.desktop.cosmic.enable = true;
    })
    (lib.mkIf (settings.desktopEnvironment == "niri") {
      sysconf = {
        desktop.niri.enable = true;
      };
    })
    # Multi-session: enable Home Manager config for both COSMIC and Niri
    (lib.mkIf (settings.desktopEnvironment == "cosmic+niri") {
      sysconf = {
        desktop = {
          cosmic.enable = true;
          niri.enable = true;
        };
      };
    })
    (lib.mkIf (settings.niriShell == "noctalia") {
      sysconf = {
        desktop.noctalia.enable = true;
        programs = {
          foot.theme = "themes/noctalia";
          ghostty.theme = "noctalia";
          zed-editor.theme = {
            mode = "system";
            dark = "Noctalia Dark";
            light = "Noctalia Light";
          };
          zen-browser = {
            userChrome = ''
              @import "${config.home.homeDirectory}/.cache/noctalia/zen-browser/zen-userChrome.css";
            '';
            userContent = ''
              @import "${config.home.homeDirectory}/.cache/noctalia/zen-browser/zen-userContent.css";
            '';
          };
        };
      };
    })
    (lib.mkIf (settings.niriShell == "dms") {
      sysconf = {
        desktop.dms.enable = true;
        programs = {
          foot.theme = "dank-colors.ini";
          ghostty.theme = "dankcolors";

          zen-browser = {
            userChrome = ''
              @import "${config.home.homeDirectory}/.config/DankMaterialShell/zen.css";
            '';
          };
        };
      };
    })
  ];
}
