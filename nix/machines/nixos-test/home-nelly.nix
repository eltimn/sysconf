{ ... }:

{
  imports = [
    ../../home/programs
    ../../home/programs/direnv.nix
    # ../../home/programs/git # requires sops
    ../../home/programs/tmux.nix
    ../../home/programs/zsh
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
