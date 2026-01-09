{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.programs.goose;
in
{
  options.sysconf.programs.goose = {
    enable = lib.mkEnableOption "goose";
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        goose-cli
      ];

      sessionVariables = {
        # Global defaults for goose
        # GOOSE_PROVIDER = "ollama";
        # GOOSE_MODEL = "gpt-oss:20b";
        # GOOSE_MODE = "smart_approve";
        # export GOOSE_LEAD_PROVIDER="gemini-cli"
        # export GOOSE_LEAD_MODEL="gemini-3-pro"
        # export GOOSE_LEAD_TURNS="5"
        # export GOOSE_PLANNER_PROVIDER="ollama"
        # export GOOSE_PLANNER_MODEL="qwen3-next:80b-cloud"

      };
    };
  };
}
