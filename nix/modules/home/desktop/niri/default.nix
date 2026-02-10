{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.niri;
  noctaliaConfigFile = "${config.home.homeDirectory}/.config/niri/noctalia.kdl";
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
        xwayland-satellite
      ];

      pointerCursor = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };

      file = {
        ".config/niri/binds.kdl".source = ./files/binds.kdl;
        ".config/niri/config.kdl".source = ./files/config.kdl;
        ".config/niri/main.kdl".source = ./files/main.kdl;
        ".config/niri/extra.kdl".text = cfg.extraConfig;
      };

      activation.initNiri = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # ensure noctalia config file exists
        if [[ ! -f "${noctaliaConfigFile}" ]]; then
          mkdir -p $(dirname "${noctaliaConfigFile}")
          touch "${noctaliaConfigFile}"
        fi
      '';
    };
  };
}

# niri regex: https://docs.rs/regex/latest/regex/#syntax
