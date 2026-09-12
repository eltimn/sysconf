# Hermes Agent gateway (Nous Research) via the nix-hermes-agent flake.
# https://github.com/0xrsydn/nix-hermes-agent
{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.sysconf.services.hermes;
in
{
  imports = [ inputs.nix-hermes.nixosModules.hermes-agent ];

  options.sysconf.services.hermes = {
    enable = lib.mkEnableOption "Hermes Agent gateway";

    environmentFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Paths to environment files containing secrets (API keys, tokens), e.g. OPENROUTER_API_KEY, ANTHROPIC_API_KEY, TELEGRAM_TOKEN.";
    };

    config = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Declarative Hermes config rendered to cli-config.yaml. Deep-merged by the hermes-agent module.";
    };

    documents = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.str lib.types.path);
      default = { };
      description = "Workspace documents (SOUL.md, AGENTS.md, USER.md, etc.). Values are inline strings or file paths.";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra packages to make available on the agent's PATH.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.hermes-agent = {
      enable = true;
      inherit (cfg)
        environmentFiles
        config
        documents
        extraPackages
        ;
    };
  };
}
