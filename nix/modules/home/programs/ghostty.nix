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
    enable = lib.mkEnableOption "ghostty";
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      systemd.enable = true;

      settings = {
        theme = "dark:cosmic-dark,light:cosmic-light";
        window-theme = "ghostty";
        font-family = "JetBrainsMono Nerd Font";
        font-size = 13;
        # keybind = [
        #   "ctrl+a>c=new_tab"
        #   "ctrl+a>w=close_surface"
        #   "ctrl+a>v=new_split:right"
        #   "ctrl+a>h=new_split:down"
        #   "ctrl+a>1=goto_tab:1"
        #   "ctrl+a>2=goto_tab:2"
        #   "ctrl+a>3=goto_tab:3"
        #   "ctrl+a>4=goto_tab:4"
        #   "ctrl+a>5=goto_tab:5"
        #   "ctrl+a>6=goto_tab:6"
        #   "ctrl+a>7=goto_tab:7"
        #   "ctrl+a>8=goto_tab:8"
        # ];
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

        # Colors from cosmic-term's built-in "COSMIC Light Dark Text" theme
        cosmic-light = {
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
