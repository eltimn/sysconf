{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.programs.zsh;
in
{
  options.sysconf.programs.zsh = {
    enable = lib.mkEnableOption "zsh";
  };

  config = lib.mkIf cfg.enable {
    home = {
      file.".config/zsh/funcs".source = ./files/funcs;

      file.".ackrc".source = ./files/ackrc;
      file.".ansible.cfg".source = ./files/ansible.cfg;
      file.".editorconfig".source = ./files/editorconfig;
      file.".mongoshrc.js".source = ./files/mongoshrc.js;

      packages = with pkgs; [
        wl-clipboard
        zsh-fzf-tab
      ];
    };

    programs = {
      zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        plugins = [ ];

        # dirHashes = {
        #   docs = "$HOME/Documents";
        #   vids = "$HOME/Videos";
        #   dl = "$HOME/Downloads";
        # };

        shellAliases = {
          codeium = "codium"; # Used by git diff tool. Doesn't  work for zsh funcs. For easily switching between code and codium.
          reload = ". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'";
          # zshrc = "codeium --new-window --wait ~/.zshrc && reload";

          la = "ls -Alh --group-directories-first";
          ll = "ls -lh --group-directories-first";

          ubuntu-version = "lsb_release -a";
          os-release = "cat /etc/os-release";
          fig = "docker compose";

          ap = "ansible-playbook";
          app = "ansible-playbook --ask-become-pass --extra-vars ansible_python_interpreter=/usr/bin/python3";

          myip = "curl icanhazip.com";

          pbcopy = "wl-copy";
          pbpaste = "wl-paste";

          ".." = "cd ..";
          "..." = "cd ../../../";
          "...." = "cd ../../../../";
          "....." = "cd ../../../../";
          ".4" = "cd ../../../../";
          ".5" = "cd ../../../../..";

          # fzf functions: https://gist.github.com/cschindlbeck/db0ac894a46aac42861e96437d8ed763

          # attach to a tmux session using fzf
          # tma = "tmux attach -t $(tmux ls  | sed -E 's/:.*$//' | grep -v \"^$(tmux display-message -p '#S')\$\"  | fzf)";

          mount-secret = "gocryptfs --idle 2h ~/secret-cipher ~/secret";
          unmount-secret = "fusermount -u ~/secret";
        };

        initContent = ''
          source ${./init.zsh}

          # Custom theme
          source ${./files/themes/philips.zsh-theme}

          # Load fzf-tab after theme is loaded
          source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        '';

      };
      # zsh = {
      #   shellInit = ''
      #     # Spaceship
      #     source ${pkgs.spaceship-prompt}/share/zsh/site-functions/prompt_spaceship_setup
      #     autoload -U promptinit; promptinit
      #     # Hook direnv
      #     #emulate zsh -c "$(direnv hook zsh)"

      #     #eval "$(direnv hook zsh)"
      #   '';
      # };

      # eza = {
      #   enable = true;
      #   git = true;
      #   icons = true;
      # };

      fzf = {
        enable = true;
        enableZshIntegration = true;
        tmux.enableShellIntegration = true;
      };

      ripgrep = {
        enable = true;
        arguments = [ ];
      };

      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
