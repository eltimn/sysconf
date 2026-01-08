{ ... }:

{
  imports = [
    ../../modules/home
  ];

  home = {
    username = "nelly";
    homeDirectory = "/home/nelly";

    sessionVariables = {
      # EDITOR = "micro";
      EDITOR = "vim";
    };

    stateVersion = "25.11"; # Don't change unless installing fresh.
  };

  # Basic user configuration
  programs.git.enable = true;
  sysconf = {
    programs.bat.enable = true;
    programs.micro.enable = true;
  };
}
