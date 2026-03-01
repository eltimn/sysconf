# Main opencode module

{
  config,
  inputs,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  cfg = config.sysconf.programs.opencode;
  tuiFileLoc = "$HOME/.config/opencode/tui.json";

  tuiAttrs = {
    "$schema" = "https://opencode.ai/tui.json";
    theme = cfg.theme;
  };

  oc = pkgs.writeShellScriptBin "oc" ''
    COSMIC_THEME_FILE="$HOME/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark"
    TUI_FILE=${tuiFileLoc}

    # Determine theme based on Cosmic theme setting
    if [[ -f "$COSMIC_THEME_FILE" ]] && [[ "$(cat "$COSMIC_THEME_FILE")" == "true" ]]; then
      THEME="tokyonight"
    else
      THEME="cosmic-light"
    fi

    # Ensure theme file exists
    if [[ ! -f "$TUI_FILE" ]]; then
      echo '{ "theme": "'"$THEME"'" }' > "$TUI_FILE"
    fi

    # Update theme in theme config
    ${pkgs.jq}/bin/jq --arg theme "$THEME" '.theme = $theme' "$TUI_FILE" > "$TUI_FILE.tmp" && \
      mv "$TUI_FILE.tmp" "$TUI_FILE"

    ${pkgs-unstable.opencode}/bin/opencode "$@"
  '';
in
{
  options.sysconf.programs.opencode = {
    enable = lib.mkEnableOption "opencode";

    theme = lib.mkOption {
      type = lib.types.str;
      description = "The OpenCode theme to use (e.g. 'cosmic-light', 'tokyonight').";
      default = "system";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."ollama_api_key" = { };

    xdg.configFile = {
      "opencode/plugin/env-protect.js".source = ./files/plugin/env-protect.js;
      "opencode/themes".source = ./files/themes;
      "opencode/AGENTS.md".source = ./files/AGENTS.md;
      "opencode/opencode.json".source = ./files/opencode.json;
      "opencode/tui-start.json".text = builtins.toJSON tuiAttrs;
      "opencode/agents".source = ./files/agents;

      # eltimn-ai-tools
      "opencode/skills/unifi-gateway-api".source = "${inputs.eltimn-ai-tools}/skills/unifi-gateway-api";
      "opencode/skills/init-new-project".source = "${inputs.eltimn-ai-tools}/skills/init-new-project";

      # Superpowers
      # "opencode/plugin/superpowers.js".source =
      #   config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/ai/superpowers/.opencode/plugin/superpowers.js";
      "opencode/command".source = ./superpowers/command; # OpenCode plugins don't support adding commands.
    };

    home = {
      # Copy tui.json as a mutable file (not symlink) so it can be edited externally
      activation.copyThemeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD cp -f "$HOME/.config/opencode/tui-start.json" ${tuiFileLoc}
        $DRY_RUN_CMD chmod u+w ${tuiFileLoc}
      '';

      sessionVariables = {
        OPENCODE_EXPERIMENTAL_LSP_TOOL = "1";
        OPENCODE_OLLAMA_CLOUD_APIKEY = "$(cat ${config.sops.secrets."ollama_api_key".path})";
      };

      packages = [ oc ];
    };

    programs.opencode = {
      enable = true;
      package = pkgs-unstable.opencode;
    };
  };
}
