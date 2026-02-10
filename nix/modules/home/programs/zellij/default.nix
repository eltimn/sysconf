{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.programs.zellij;

  zellij-session-picker = pkgs.writeShellScriptBin "zellij-session-picker" ''
    set -euo pipefail

    # Ensure zellij is available
    command -v zellij >/dev/null 2>&1 || { echo "Error: zellij not found" >&2; exit 1; }

    # Get list of sessions, treating "no sessions" as empty
    ZJ_SESSIONS=$(zellij list-sessions 2>/dev/null) || ZJ_SESSIONS=""

    if [ -z "''${ZJ_SESSIONS}" ]; then
      # No existing sessions - create new one
      exec zellij attach -c
    fi

    # Let user choose a session
    SESSION_LINE=$(echo "''${ZJ_SESSIONS}" | ${pkgs.gum}/bin/gum choose --header "Select zellij session:") || {
      # User cancelled or error - create new session
      exec zellij attach -c
    }

    if [ -z "''${SESSION_LINE}" ]; then
      exec zellij attach -c
    fi

    # Extract session name (first field)
    SESSION="''${SESSION_LINE%% *}"

    # Validate session name to prevent injection
    if [[ ! "''${SESSION}" =~ ^[a-zA-Z0-9_-]+$ ]]; then
      echo "Error: Invalid session name format: ''${SESSION}" >&2
      exit 1
    fi

    # Attach to selected session
    exec zellij attach "''${SESSION}"
  '';
in
{
  options.sysconf.programs.zellij = {
    enable = lib.mkEnableOption "zellij";
  };

  config = lib.mkIf cfg.enable {
    programs.zellij.enable = true;

    home = {
      file.".config/zellij/config.kdl".source = pkgs.replaceVars ./tmpl-config.kdl {
        scrollback_editor = "${pkgs.neovim}/bin/nvim";
      };

      packages = [
        zellij-session-picker
        pkgs.gum
      ];

      shellAliases = {
        zj = "zellij";
        zjs = "zellij-session-picker";
      };
    };
  };
}
