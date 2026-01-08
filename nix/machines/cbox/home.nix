{
  osConfig,
  ...
}:
{

  imports = [
    ../../modules/home/common
    ../../modules/home/programs
    ../../modules/home/programs/direnv.nix
    ../../modules/home/programs/git
    ../../modules/home/programs/tmux.nix
    ../../modules/home/programs/zsh
  ];

  # The User and Path it manages
  home = {
    username = "${osConfig.sysconf.settings.primaryUsername}";
    homeDirectory = "/home/${osConfig.sysconf.settings.primaryUsername}";
    stateVersion = "23.11"; # don't change unless reinstalling from scratch

    sessionPath = [
      "$HOME/bin/common"
      "$HOME/bin"
    ];

    sessionVariables = {
      EDITOR = "micro";
    };
  };

  programs = {
    # Let Home Manager manage itself
    home-manager.enable = true;
  };

  sysconf = {
    programs.bat.enable = true;
    programs.micro.enable = true;
  };
}
