{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.programs.zellij;

  zellij-session-picker = pkgs.writeShellScriptBin "zellij-session-picker" ''
    #!/usr/bin/env bash
    set -euo pipefail

    ZJ_SESSIONS=$(zellij list-sessions 2>/dev/null || true)

    if [ -z "''${ZJ_SESSIONS}" ]; then
      zellij attach -c
    else
      SESSION_LINE=$(echo "''${ZJ_SESSIONS}" | ${pkgs.gum}/bin/gum choose --header "Select zellij session:")
      if [ -n "''${SESSION_LINE}" ]; then
        SESSION=$(echo "''${SESSION_LINE}" | awk '{print $1}')
        zellij attach "''${SESSION}"
      else
        zellij attach -c
      fi
    fi
  '';
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

    home.packages = [ zellij-session-picker ];

    # Create a shell alias for easy session attachment
    home.shellAliases = {
      zjs = "zellij-session-picker";
    };
  };
}
