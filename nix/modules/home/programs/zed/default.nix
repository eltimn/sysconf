{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.programs.zed-editor;

  # Read the nix-module templates
  nixModuleTemplate = builtins.readFile ./snippets/nix-module.nix-tmpl;
  nixOptTemplate = builtins.readFile ./snippets/nix-opt.nix-tmpl;

  # Create the snippets JSON structure
  snippetsJson = {
    "Nix module" = {
      prefix = "nm";
      body = lib.splitString "\n" nixModuleTemplate;
      description = "New Nix module with enable option.";
    };
    "Nix option" = {
      prefix = "opt";
      body = lib.splitString "\n" nixOptTemplate;
      description = "New nix option.";
    };
  };
in
{
  options.sysconf.programs.zed-editor = {
    enable = lib.mkEnableOption "zed-editor";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nil
      nixd
      rumdl
    ];

    # https://home-manager-options.extranix.com/?query=programs.zed-editor&release=release-25.11
    programs.zed-editor = {
      enable = true;
      extensions = [
        "git-firefly"
        "gleam"
        "html"
        "kdl"
        "lua"
        "make"
        "nix"
        "opencode"
        "opentofu"
        "rumdl"
        "sql"
        "templ"
        "toml"
        "xml"
      ];
      userSettings = {
        theme = {
          mode = "system";
          dark = "Noctalia Dark";
          light = "One Light";
        };
        file_types = {
          "Shell Script" = [
            ".env.*"
            ".envrc"
          ];
        };
        lsp = {
          nixd = {
            settings = {
              formatting = {
                command = [ "nixfmt" ];
              };
            };
          };
        };
        theme_overrides = {
          "One Light" = {
            "editor.background" = "#eef5eb"; # Custom background color for One Light theme
          };
        };
        agent_servers = {
          OpenCode = {
            type = "custom";
            command = "${config.programs.opencode.package}/bin/opencode";
            args = [ "acp" ];
          };
        };
        features = {
          edit_prediction_provider = "copilot";
        };
      };
    };

    # Generate snippets file
    home.file.".config/zed/snippets/nix.json" = {
      text = builtins.toJSON snippetsJson;
    };
  };
}
