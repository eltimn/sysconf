{
  pkgs,
  osConfig,
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
      LESSOPEN = "|bat --paging=never --color=always %s"; # use bat for syntax highlighting with less
    };
  };

  programs = {
    # Let Home Manager manage itself
    home-manager.enable = true;
  };

  sysconf = {
    programs.micro.enable = true;
  };
}
