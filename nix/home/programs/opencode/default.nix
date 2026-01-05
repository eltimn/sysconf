# Main opencode module

{
  config,
  lib,
  pkgs-unstable,
  ...
}:

let
  cfg = config.sysconf.programs.opencode;
in
{
  imports = [
    ./rules.nix
    ./provider.nix
    ./agents.nix
  ];

  options.sysconf.programs.opencode = {
    enable = lib.mkEnableOption "opencode";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."ollama_api_key" = { };

    home.sessionVariables = {
      OPENCODE_DISABLE_AUTOUPDATE = "1";
      OPENCODE_EXPERIMENTAL_LSP_TOOL = "1";
      OPENCODE_OLLAMA_CLOUD_APIKEY = "$(cat ${config.sops.secrets."ollama_api_key".path})";
    };

    programs.opencode = {
      enable = true;
      package = pkgs-unstable.opencode;

      # Creates ~/.config/opencode/opencode.json
      settings = {
        tools = {
          lsp = true;
          nixos = false; # don't enable by default
        };

        mcp = { };

        permission = {
          bash = {
            "git push" = "ask";
            "task switch" = "ask";
            "nixos-rebuild switch" = "ask";
            "sudo" = "deny";
          };
        };
        agent = {
          build = {
            permission = {
              bash = {
                "git push" = "allow";
              };
            };
          };
          plan = {
            tools = {
              nixos = true;
            };
          };
        };
      };
    };
  };
}
