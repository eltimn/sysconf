{ osConfig, ... }:

{
  imports = [
    ../../modules/home
  ];

  home = {
    username = "nelly";
    homeDirectory = "/home/nelly";

    sessionVariables = {
      EDITOR = osConfig.sysconf.users.nelly.envEditor;
    };

    stateVersion = "25.11"; # Don't change unless installing fresh.
  };

  # Basic user configuration
  sysconf = {
    programs.bat.enable = true;
    programs.micro.enable = true;

    programs.git = {
      githubIncludePath = "/run/keys/nelly-git-github";
      userIncludePath = "/run/keys/nelly-git-user";
    };
  };
}
