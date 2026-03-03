{
  config,
  lib,
  osConfig,
  ...
}:
let
  cfg = config.sysconf.programs.ghostty;
  fonts = osConfig.sysconf.fonts;
in
{
  options.sysconf.programs.ghostty = {
    enable = lib.mkEnableOption "ghostty";

    theme = lib.mkOption {
      type = lib.types.str;
      description = "The theme name.";
      default = "dark:sysconf-dark,light:sysconf-light";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      systemd.enable = true;

      settings = {
        theme = cfg.theme;
        window-theme = "ghostty";
        font-family = fonts.monospace;
        font-size = fonts.size - 1;
        quit-after-last-window-closed = false;
      };

      themes = {
        # Colors from cosmic-term's built-in "COSMIC Dark" theme
        # cosmic-nord = {
        #   background = "#2E3440";
        #   cursor-color = "C4C4C4";
        #   foreground = "C4C4C4";
        #   palette = [
        #     "0=#1B1B1B"
        #     "1=#F16161"
        #     "2=#7CB987"
        #     "3=#DDC74C"
        #     "4=#6296BE"
        #     "5=#BE6DEE"
        #     "6=#49BAC8"
        #     "7=#BEBEBE"
        #     "8=#808080"
        #     "9=#FF8985"
        #     "10=#97D5A0"
        #     "11=#FAE365"
        #     "12=#7DB1DA"
        #     "13=#D68EFF"
        #     "14=#49BAC8"
        #     "15=#C4C4C4"
        #   ];
        #   selection-background = "3A3A3A";
        #   selection-foreground = "C4C4C4";
        # };

        # based on tokyo night from noctalia
        sysconf-dark = {
          background = "#1a1b26";
          foreground = "#c0caf5";
          cursor-color = "#c0caf5";
          cursor-text = "#1a1b26";

          palette = [
            "0=#15161e"
            "1=#f7768e"
            "2=#9ece6a"
            "3=#e0af68"
            "4=#7aa2f7"
            "5=#bb9af7"
            "6=#7dcfff"
            "7=#a9b1d6"
            "8=#414868"
            "9=#f7768e"
            "10=#9ece6a"
            "11=#e0af68"
            "12=#7aa2f7"
            "13=#bb9af7"
            "14=#7dcfff"
            "15=#c0caf5"
          ];

          selection-background = "#283457";
          selection-foreground = "#c0caf5";
        };

        # Colors from cosmic-term's built-in "COSMIC Light Dark Text" theme
        sysconf-light = {
          background = "F5F7FA";
          cursor-color = "1B1B1B";
          foreground = "1B1B1B";
          palette = [
            "0=#5C5F77"
            "1=#D20F39"
            "2=#40A02B"
            "3=#DF8E1D"
            "4=#1E66F5"
            "5=#EA76CB"
            "6=#179299"
            "7=#ACB0BE"
            "8=#6C6F85"
            "9=#D20F39"
            "10=#40A02B"
            "11=#DF8E1D"
            "12=#1E66F5"
            "13=#EA76CB"
            "14=#179299"
            "15=#BCC0CC"
          ];
          selection-background = "ACB0BE";
          selection-foreground = "1B1B1B";
        };
      };
    };
  };
}
