{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.programs.zed-editor;
  fonts = osConfig.sysconf.fonts;
  fontSize = fonts.size + 1;

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
          dark = "Tokyo Night";
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

        # fonts
        ui_font_family = fonts.sansSerif;
        ui_font_size = fontSize;
        buffer_font_size = fontSize;
        buffer_font_family = fonts.monospace;
        terminal = {
          font_size = fontSize;
          # Terminal line height: comfortable (1.618), standard(1.3) or `{ "custom": 2 }`
          line_height = "standard";
        };
      };
    };

    # Generate snippets file
    home.file.".config/zed/snippets/nix.json" = {
      text = builtins.toJSON snippetsJson;
    };
  };
}
