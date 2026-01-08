{ lib, osConfig, ... }:
let
  settings = osConfig.sysconf.settings;
in
{
  imports = [
    ./cosmic
    ./gnome.nix
  ];

  config = lib.mkMerge [
    (lib.mkIf (settings.desktopEnvironment == "gnome") {
      sysconf.desktop.gnome.enable = true;
    })
    (lib.mkIf (settings.desktopEnvironment == "cosmic") {
      sysconf.desktop.cosmic.enable = true;
    })
  ];
}
