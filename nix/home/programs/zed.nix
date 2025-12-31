{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.home.programs.zed-editor;
in
{
  options.sysconf.home.programs.zed-editor = {
    enable = lib.mkEnableOption "zed-editor";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nil
      nixd
    ];

    programs.zed-editor = {
      enable = true;
      extensions = [
        "html"
        "nix"
        "templ"
      ];
    };
  };
}
