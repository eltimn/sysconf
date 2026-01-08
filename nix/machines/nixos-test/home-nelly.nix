{ ... }:

{
  imports = [
    ../../modules/home
  ];

  home.stateVersion = "25.11";

  # Basic user configuration
  programs.git.enable = true;
  sysconf = {
    programs.bat.enable = true;
    programs.micro.enable = true;
  };

  # home.packages = with pkgs; [
  #   micro
  # ];

  home.sessionVariables = {
    # EDITOR = "micro";
    EDITOR = "vim";
  };
}
