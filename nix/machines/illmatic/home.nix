{
  config,
  pkgs,
  vars,
  ...
}:
{

  imports = [
    ../../home/common
    ../../home/programs/direnv.nix
    ../../home/programs/git
    ../../home/programs/tmux.nix
    ../../home/programs/zsh
  ];

  home = {
    username = "${vars.user}";
    homeDirectory = "/home/${vars.user}";
    stateVersion = "24.05";

    packages = with pkgs; [
      gnumake
      nixfmt-classic
      stow
    ];

    sessionPath = [ "$HOME/bin/common" ];
    sessionVariables = {
      EDITOR = "${vars.editor}";
    };
  };

  # Packages that are installed as programs also allow for configuration.
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };
}
