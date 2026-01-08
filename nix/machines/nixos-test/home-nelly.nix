{ ... }:

{
  imports = [
    ../../modules/home/programs
    ../../modules/home/programs/direnv.nix
    # ../../modules/home/programs/git # requires sops
    ../../modules/home/programs/tmux.nix
    ../../modules/home/programs/zsh
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
