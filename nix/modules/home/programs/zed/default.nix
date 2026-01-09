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
    ];

    # https://home-manager-options.extranix.com/?query=programs.zed-editor&release=release-25.11
    programs.zed-editor = {
      enable = true;
      extensions = [
        "git-firefly"
        "html"
        "nix"
        "opentofu"
        "sql"
        "templ"
        "toml"
        "xml"
      ];
      userSettings = {
        file_types = {
          "Shell Script" = [
            ".env.*"
            ".envrc"
          ];
        };
        theme_overrides = {
          "One Light" = {
            "editor.background" = "#eef5eb"; # Custom background color for One Light theme
          };
        };
      };
    };

    # Generate snippets file
    home.file.".config/zed/snippets/nix.json" = {
      text = builtins.toJSON snippetsJson;
    };
  };
}
