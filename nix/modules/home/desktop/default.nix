{ lib, osConfig, ... }:
let
  settings = osConfig.sysconf.settings;
in
{
  imports = [
    ./cosmic
    ./niri
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
      sysconf.desktop.niri.enable = true;
      sysconf.desktop.noctalia.enable = true;
    })
    # Multi-session: enable Home Manager config for both COSMIC and Niri
    (lib.mkIf (settings.desktopEnvironment == "cosmic+niri") {
      sysconf.desktop = {
        cosmic.enable = true;
        niri.enable = true;
        noctalia.enable = true;
      };
    })
  ];
}
