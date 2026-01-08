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
        # Access extensions from nix-vscode-extensions overlay
        # https://nix-community.github.io/nix-vscode-extensions
        extensions =
          # standard nix packages
          (with pkgs.vscode-extensions; [
            editorconfig.editorconfig
            github.copilot
            github.copilot-chat
            golang.go
            jnoortheen.nix-ide
            matthewpi.caddyfile-support
            yzhang.markdown-all-in-one

            # hashicorp.terraform
            # ms-python.python
            # redhat.ansible
            redhat.vscode-yaml
          ])
          # Open VSX via nix-vscode-extensions
          ++ (with pkgs.open-vsx; [
            continue.continue
            hongquan.dragon-jinja
            # kilocode.kilo-code
            # kochan.vs-nord-theme
            opentofu.vscode-opentofu
          ]);
        # VSCode Marketplace via nix-vscode-extensions
        # ++ (with pkgs.vscode-marketplace; [
        #   # kilocode.kilo-code
        # ]);
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
