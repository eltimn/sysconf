{
  config,
  lib,
  osConfig,
  ...
}:
let
  cfg = config.sysconf.programs.foot;
  fonts = osConfig.sysconf.fonts;
in
{
  options.sysconf.programs.foot = {
    enable = lib.mkEnableOption "foot";

    theme = lib.mkOption {
      type = lib.types.str;
      description = "Name of the theme file.";
      default = "default";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;
      server.enable = true;

      settings = {
        main = {
          include = "${config.home.homeDirectory}/.config/foot/themes/${cfg.theme}";
          term = "xterm-256color";
          font = "monospace:size=${toString fonts.size}";
          pad = "12x12";
          dpi-aware = "yes";
          initial-window-size-chars = "100x30";
          initial-window-mode = "windowed";
          word-delimiters = ",│`|:\"'()[]{}<>";
          selection-target = "clipboard";
        };

        cursor = {
          style = "block";
          blink = "yes";
        };

        mouse = {
          hide-when-typing = "yes";
        };

        key-bindings = {
          scrollback-up-page = "Shift+Page_Up";
          scrollback-down-page = "Shift+Page_Down";
          scrollback-up-line = "Shift+Up";
          scrollback-down-line = "Shift+Down";
          clipboard-copy = "Control+Shift+c";
          clipboard-paste = "Control+Shift+v";
          primary-paste = "Shift+Insert";
          search-start = "Control+Shift+f";
          font-increase = "Control+plus";
          font-decrease = "Control+minus";
          font-reset = "Control+0";
          spawn-terminal = "Control+Shift+n";
          # show-urls-launch = "Control+Shift+u";
        };

        search-bindings = {
          cancel = "Escape";
          commit = "Return";
          find-prev = "Control+Shift+p";
          find-next = "Control+Shift+n";
        };

        url-bindings = {
          cancel = "Escape";
          toggle-url-visible = "Control+Shift+u";
        };
      };
    };

    home.file.".config/foot/themes/default".text = ''
      [colors]
      alpha=0.95
      background=1a1a1a
      foreground=d4d4d4
      cursor=111111 cccccc
      regular0=1a1a1a
      regular1=ff5f56
      regular2=5af78e
      regular3=f3f99d
      regular4=57c7ff
      regular5=ff6ac1
      regular6=9aedfe
      regular7=f1f1f0
      bright0=686868
      bright1=ff5f56
      bright2=5af78e
      bright3=f3f99d
      bright4=57c7ff
      bright5=ff6ac1
      bright6=9aedfe
      bright7=f1f1f0
    '';
  };
}
