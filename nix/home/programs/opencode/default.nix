# Main opencode module

{
  config,
  lib,
  osConfig,
  pkgs-unstable,
  ...
}:

let
  cfg = config.sysconf.programs.opencode;
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

    programs.opencode = {
      enable = true;
      package = pkgs-unstable.opencode;
    };
  };
}
