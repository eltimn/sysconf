{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.programs.ghostty;
in
{
  options.sysconf.programs.ghostty = {
    enable = lib.mkEnableOption {
      default = false;
      type = lib.types.bool;
      description = "ghostty";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      systemd.enable = true;

      settings = {
        theme = "dark:cosmic-dark,light:custom-light";
        window-theme = "ghostty";
        font-family = "DejaVu Sans Mono";
        font-size = 13;
        keybind = [
          "ctrl+a>c=new_tab"
          "ctrl+a>w=close_surface"
          "ctrl+a>v=new_split:right"
          "ctrl+a>h=new_split:down"
          "ctrl+a>1=goto_tab:1"
          "ctrl+a>2=goto_tab:2"
          "ctrl+a>3=goto_tab:3"
          "ctrl+a>4=goto_tab:4"
          "ctrl+a>5=goto_tab:5"
          "ctrl+a>6=goto_tab:6"
          "ctrl+a>7=goto_tab:7"
          "ctrl+a>8=goto_tab:8"
        ];
      };

      themes = {
        # Colors from cosmic-term's built-in "COSMIC Dark" theme
        cosmic-dark = {
          background = "#2E3440";
          cursor-color = "C4C4C4";
          foreground = "C4C4C4";
          palette = [
            "0=#1B1B1B"
            "1=#F16161"
            "2=#7CB987"
            "3=#DDC74C"
            "4=#6296BE"
            "5=#BE6DEE"
            "6=#49BAC8"
            "7=#BEBEBE"
            "8=#808080"
            "9=#FF8985"
            "10=#97D5A0"
            "11=#FAE365"
            "12=#7DB1DA"
            "13=#D68EFF"
            "14=#49BAC8"
            "15=#C4C4C4"
          ];
          selection-background = "3A3A3A";
          selection-foreground = "C4C4C4";
        };

        custom-light = {
          background = "faf4f2";
          cursor-color = "706b6e";
          foreground = "29242a";
          palette = [
            "0=#faf4f2"
            "1=#e14775"
            "2=#269d69"
            "3=#cc7a0a"
            "4=#e16032"
            "5=#7058be"
            "6=#1c8ca8"
            "7=#29242a"
            "8=#a59fa0"
            "9=#e14775"
            "10=#269d69"
            "11=#cc7a0a"
            "12=#e16032"
            "13=#7058be"
            "14=#1c8ca8"
            "15=#29242a"
          ];
          selection-background = "bfb9ba";
          selection-foreground = "29242a";
        };
      };
    };
  };
}
