{ lib, osConfig, ... }:
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
        programs.foot.theme = "noctalia";
        programs.ghostty.theme = "noctalia";
      };
    })
    # Multi-session: enable Home Manager config for both COSMIC and Niri
    (lib.mkIf (settings.desktopEnvironment == "cosmic+niri") {
      sysconf = {
        desktop = {
          cosmic.enable = true;
          niri.enable = true;
        };

        programs = {
          foot.theme = "noctalia";
          ghostty.theme = "noctalia";
        };
      };
    })
    (lib.mkIf (settings.niriShell == "noctalia") {
      sysconf.desktop.noctalia.enable = true;
    })
    (lib.mkIf (settings.niriShell == "dms") {
      sysconf.desktop.dms.enable = true;
    })
  ];
}
