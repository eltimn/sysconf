{ ... }:

{
  imports = [
    ../../home/programs/direnv.nix
    # ../../home/programs/git # requires sops
    ../../home/programs/micro.nix
    ../../home/programs/tmux.nix
    ../../home/programs/zsh
  ];

  home.stateVersion = "25.11";

  # Basic user configuration
  programs.git.enable = true;
  sysconf.programs.micro.enable = true;

  # home.packages = with pkgs; [
  #   micro
  # ];

  home.sessionVariables = {
    # EDITOR = "micro";
    EDITOR = "vim";
  };
}
