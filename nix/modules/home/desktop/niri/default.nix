{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.niri;
in
{
  options.sysconf.desktop.niri = {
    enable = lib.mkEnableOption "niri";

    extraConfig = lib.mkOption {
      type = lib.types.str;
      description = "Extra config to add to Niri";
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        niri
        foot
        wl-clipboard
      ];

      file = {
        ".config/niri/binds.kdl".source = ./files/binds.kdl;
        ".config/niri/config.kdl".source = ./files/config.kdl;
        ".config/niri/main.kdl".source = ./files/main.kdl;
        ".config/niri/extra.kdl".text = cfg.extraConfig;
      };
    };
  };
}

# niri regex: https://docs.rs/regex/latest/regex/#syntax
