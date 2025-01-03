{ pkgs, vars, ... }:

{
  home = {
    # file.".config/Code/User/settings.json".source = ./files/settings.json;
    # file.".config/VSCodium/User/settings.json".source = ./files/settings.json;

    packages = with pkgs; [
      nil
      nixfmt-rfc-style
    ];
  };

  programs = {
    # https://mynixos.com/home-manager/options/programs.vscode
    vscode = {
      enable = true;
      package = pkgs.vscodium;
      # enableExtensionUpdateCheck = false;
      # enableUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        golang.go
        hashicorp.terraform
        jnoortheen.nix-ide
        # ms-python.python
        # redhat.ansible
        # redhat.vscode-yaml
        # sumneko.lua
        yzhang.markdown-all-in-one
      ];
      # userSettings = {
      # };
      globalSnippets = {
        fixme = {
          body = [ "$LINE_COMMENT FIXME: $0" ];
          description = "Insert a FIXME remark";
          prefix = [ "fixme" ];
        };
      };
    };
  };
}
