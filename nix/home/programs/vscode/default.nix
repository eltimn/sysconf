{ pkgs, pkgs-unstable, ... }:

{
  home = {
    packages = with pkgs; [
      nil
      nixfmt-rfc-style
    ];
  };

  programs = {
    # https://mynixos.com/home-manager/options/programs.vscode
    vscode = {
      enable = true;
      package = pkgs-unstable.vscodium;

      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          editorconfig.editorconfig
          github.copilot
          github.copilot-chat
          golang.go
          hashicorp.terraform
          jnoortheen.nix-ide
          # ms-python.python
          # redhat.ansible
          # redhat.vscode-yaml
          # sumneko.lua
          yzhang.markdown-all-in-one
        ];
        globalSnippets = {
          fixme = {
            body = [ "$LINE_COMMENT FIXME: $0" ];
            description = "Insert a FIXME remark";
            prefix = [ "fixme" ];
          };
        };
      };
    };
  };
}
