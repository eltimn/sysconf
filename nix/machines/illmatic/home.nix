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
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "24.05";

    packages = with pkgs; [
      gnumake
      nixfmt-classic
      stow
    ];

    sessionPath = [ "$HOME/bin/common" ];
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  # Packages that are installed as programs also allow for configuration.
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };
}
