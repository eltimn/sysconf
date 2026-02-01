{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.programs.zellij;
in
{
  options.sysconf.programs.zellij = {
    enable = lib.mkEnableOption "zellij";
  };

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;

      settings = {
        theme = "nord";
        default_layout = "compact";
        default_shell = "zsh";
        pane_frames = false;
        simplified_ui = true;
        copy_clipboard = "system";
        copy_on_select = true;
        scrollback_editor = "${pkgs.micro}/bin/micro";
      };
    };

    # Create a shell alias for easy session attachment
    home.shellAliases = {
      zj = "zellij";
      zja = "zellij attach";
    };
  };
}
