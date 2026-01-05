{ ... }:

{
  imports = [
    ../../home/programs/direnv.nix
    # ../../home/programs/git # requires sops
    ../../home/programs/tmux.nix
    ../../home/programs/zsh
  ];

  home.stateVersion = "25.11";

  # Basic user configuration
  programs.git.enable = true;

  # home.packages = with pkgs; [
  #   fresh-editor
  # ];

  home.sessionVariables = {
    # EDITOR = "fresh --no-session";
    EDITOR = "vim";
  };
}
