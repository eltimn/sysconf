{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;

    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 50000;
    keyMode = "vi";
    mouse = true;
    shell = "${pkgs.zsh}/bin/zsh";
    shortcut = "a";
    # terminal = "screen-256color";
    plugins = with pkgs; [
      # tmuxPlugins.sensible
      tmuxPlugins.yank
    ];
    extraConfig = ''
      set -g status-bg blue
      set -g status-fg white
      # unbind-key -T copy-mode-vi v
      # bind-key -T copy-mode-vi 'v' send -X begin-selection     # Begin selection in copy mode.
      # bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle  # Begin selection in copy mode.
      # bind-key -T copy-mode-vi 'y' send -X copy-selection      # Yank selection in copy mode.
      # bind P paste-buffer # Paste the buffer
      # bind -t vi-copy y copy-pipe "xclip -sel clip -i" # send buffer to system clipboard
    '';
  };
}
