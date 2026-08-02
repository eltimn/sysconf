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

    stateVersion = "26.05"; # Don't change unless installing fresh.
  };

  # Basic user configuration
  sysconf.programs = {
    bat.enable = true;
    micro.enable = true;

    git = {
      githubIncludePath = "/run/keys/nelly-git-github";
      userIncludePath = "/run/keys/nelly-git-user";
    };
  };
}
