# Main opencode module

{
  config,
  lib,
  osConfig,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  cfg = config.sysconf.programs.opencode;

  oc = pkgs.writeShellScriptBin "oc" ''
    COSMIC_THEME_FILE="$HOME/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark"
    THEME_FILE="$HOME/.config/opencode/theme.json"

    # Determine theme based on Cosmic theme setting
    if [[ -f "$COSMIC_THEME_FILE" ]] && [[ "$(cat "$COSMIC_THEME_FILE")" == "true" ]]; then
      THEME="palenight"
    else
      THEME="cosmic-light"
    fi

    # Ensure theme file exists
    if [[ ! -f "$THEME_FILE" ]]; then
      echo '{ "theme": "'"$THEME"'" }' > "$THEME_FILE"
    fi

    # Update theme in theme config
    ${pkgs.jq}/bin/jq --arg theme "$THEME" '.theme = $theme' "$THEME_FILE" > "$THEME_FILE.tmp" && \
      mv "$THEME_FILE.tmp" "$THEME_FILE"

    # Set OPENCODE_CONFIG to point to theme file (merged with main config)
    export OPENCODE_CONFIG="$THEME_FILE"

    ${pkgs-unstable.opencode}/bin/opencode "$@"
  '';
in
{
  options.sysconf.programs.opencode = {
    enable = lib.mkEnableOption "opencode";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."ollama_api_key" = { };

    # Symlink config directories
    home.file.".config/opencode/themes".source = ./files/themes;
    home.file.".config/opencode/command".source = ./files/command;
    home.file.".config/opencode/agent".source = ./files/agent;
    home.file.".config/opencode/AGENTS.md".source = ./files/AGENTS.md;

    # Symlink main config (immutable)
    home.file.".config/opencode/opencode.json".source = ./files/opencode.json;

    # Copy theme.json as a mutable file (not symlink) so it can be edited externally
    home.activation.copyThemeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD cp -f ${./files/theme.json} "$HOME/.config/opencode/theme.json"
      $DRY_RUN_CMD chmod u+w "$HOME/.config/opencode/theme.json"
    '';

    home.sessionVariables = {
      OPENCODE_EXPERIMENTAL_LSP_TOOL = "1";
      OPENCODE_OLLAMA_BASEURL = "http://${osConfig.services.ollama.host}:${toString osConfig.services.ollama.port}/v1/";
      OPENCODE_OLLAMA_CLOUD_APIKEY = "$(cat ${config.sops.secrets."ollama_api_key".path})";
    };

    home.packages = [ oc ];

    programs.opencode = {
      enable = true;
      package = pkgs-unstable.opencode;
    };
  };
}
