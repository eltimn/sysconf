{ pkgs, vars, ... }:

{
  home = {
    # file.".config/Code/User/settings.json".source = ./files/settings.json;
    file.".config/VSCodium/User/settings.json".source = ./files/settings.json;
  };

  programs = {
    # https://mynixos.com/home-manager/options/programs.vscode
    vscode = {
      enable = true;
      package = pkgs.vscodium;
      # enableExtensionUpdateCheck = false;
      # enableUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        hashicorp.terraform
        yzhang.markdown-all-in-one
      ];
      # userSettings = {
      # };
      globalSnippets = {
        fixme = {
          body = [
            "$LINE_COMMENT FIXME: $0"
          ];
          description = "Insert a FIXME remark";
          prefix = [
            "fixme"
          ];
        };
      };
    };
  };
}
