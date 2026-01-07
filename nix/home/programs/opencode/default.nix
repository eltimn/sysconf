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
  ];

  options.sysconf.programs.opencode = {
    enable = lib.mkEnableOption "opencode";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."ollama_api_key" = { };

    # Symlink config directories
    home.file.".config/opencode/themes".source = ./themes;
    home.file.".config/opencode/command".source = ./commands;
    home.file.".config/opencode/agent".source = ./agents;

    home.sessionVariables = {
      OPENCODE_EXPERIMENTAL_LSP_TOOL = "1";
      OPENCODE_OLLAMA_CLOUD_APIKEY = "$(cat ${config.sops.secrets."ollama_api_key".path})";
    };

    programs.opencode = {
      enable = true;
      package = pkgs-unstable.opencode;

      # Creates ~/.config/opencode/opencode.json
      settings = {
        autoupdate = false;
        theme = "cosmic-light"; # TODO: system doesn't switch between light/dark themes, this will need to be manually done: https://opencode.ai/docs/themes/#system-theme
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
