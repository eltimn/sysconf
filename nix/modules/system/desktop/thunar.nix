{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.thunar;
in
{
  options.sysconf.desktop.thunar = {
    enable = lib.mkEnableOption "thunar";
  };

  config = lib.mkIf cfg.enable {
    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    environment.systemPackages = with pkgs; [
      file-roller
    ];

    programs.xfconf.enable = true; # Needed to save preferences when not using XFCE desktop environment

    services.gvfs.enable = true; # Mount, trash, and other functionalities
    services.tumbler.enable = true; # Thumbnail support for images
  };
}
