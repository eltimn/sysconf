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
        # Format: pkgs.vscode-extensions.<publisher>.<extension-name>
        extensions = with pkgs.vscode-extensions; [
          editorconfig.editorconfig
          github.copilot
          github.copilot-chat
          golang.go
          # hongquan.dragon-jinja
          jnoortheen.nix-ide
          # kilocode.kilo-code
          matthewpi.caddyfile-support
          # opentofu.vscode-opentofu
          yzhang.markdown-all-in-one

          # continue.continue
          # hashicorp.terraform
          # ms-python.python
          # redhat.ansible
          # redhat.vscode-yaml
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
