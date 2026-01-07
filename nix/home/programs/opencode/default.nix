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
    OPENCODE_CONFIG="$HOME/.config/opencode/opencode.json"

    if [[ -f "$COSMIC_THEME_FILE" ]] && [[ "$(cat "$COSMIC_THEME_FILE")" == "true" ]]; then
      THEME="palenight"
    else
      THEME="cosmic-light"
    fi

    # Update theme in opencode config
    if [[ -f "$OPENCODE_CONFIG" ]]; then
      ${pkgs.jq}/bin/jq --arg theme "$THEME" '.theme = $theme' "$OPENCODE_CONFIG" > "$OPENCODE_CONFIG.tmp" && \
        mv "$OPENCODE_CONFIG.tmp" "$OPENCODE_CONFIG"
    fi

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

    # Copy opencode.json as a mutable file (not symlink) so theme can be edited externally
    home.activation.copyOpencodeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD cp -f ${./files/opencode.json} "$HOME/.config/opencode/opencode.json"
      $DRY_RUN_CMD chmod u+w "$HOME/.config/opencode/opencode.json"
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
