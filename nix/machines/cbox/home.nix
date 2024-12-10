{ pkgs, vars, ... }:
{

  imports = [
    ../../home/common
    ../../home/programs/direnv.nix
    ../../home/programs/git
    ../../home/programs/tmux.nix
    ../../home/programs/zsh
  ];

  # The User and Path it manages
  home = {
    username = "${vars.user}";
    homeDirectory = "/home/${vars.user}";
    stateVersion = "23.11"; # don't change unless reinstalling from scratch

    packages = with pkgs; [
      gnumake
      stow
    ];

    sessionPath = [ "$HOME/bin/common" ];
    sessionVariables = {
      EDITOR = "${vars.editor}";
    };
  };

  # Packages that are installed as programs also allow for configuration.
  programs = {
    # Let Home Manager manage itself
    home-manager.enable = true;
  };
}
