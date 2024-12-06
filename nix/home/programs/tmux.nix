{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    mouse = true;
    shell = "${pkgs.zsh}/bin/zsh";
    shortcut = "a";
    # terminal = "screen-256color";
    # plugins = with pkgs; [ tmuxPlugins.sensible tmuxPlugins.cpu ];
    extraConfig = ''
      set -g status-bg blue
      set -g status-fg white
      set -g base-index      1
      setw -g pane-base-index 1
    '';
  };
}
