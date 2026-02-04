{ lib, osConfig, ... }:
let
  settings = osConfig.sysconf.settings;
in
{
  imports = [
    ./cosmic
    ./niri
    ./gnome.nix
  ];

  config = lib.mkMerge [
    {
      home.file."background-image".source = ./lightning-wallpaper;
    }
    (lib.mkIf (settings.desktopEnvironment == "gnome") {
      sysconf.desktop.gnome.enable = true;
    })
    (lib.mkIf (settings.desktopEnvironment == "cosmic") {
      sysconf.desktop.cosmic.enable = true;
    })
    (lib.mkIf (settings.desktopEnvironment == "niri") {
      sysconf.desktop.niri.enable = true;
    })
    # Multi-session: enable Home Manager config for both COSMIC and Niri
    (lib.mkIf (settings.desktopEnvironment == "cosmic+niri") {
      sysconf.desktop.cosmic.enable = true;
      sysconf.desktop.niri.enable = true;
    })
  ];
}
