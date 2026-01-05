{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.programs.zed-editor;

  # Read the nix-module template
  nixModuleTemplate = builtins.readFile ./snippets/nix-module.nix-tmpl;

  # Create the snippets JSON structure
  snippetsJson = {
    "Nix module" = {
      prefix = "nm";
      body = lib.splitString "\n" nixModuleTemplate;
      description = "New Nix module with enable option.";
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

    programs.zed-editor = {
      enable = true;
      extensions = [
        "git-firefly"
        "html"
        "nix"
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
      };
    };

    # Generate snippets file
    home.file.".config/zed/snippets/nix.json" = {
      text = builtins.toJSON snippetsJson;
    };
  };
}
