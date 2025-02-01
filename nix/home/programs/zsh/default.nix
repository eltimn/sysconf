{ ... }:

{
  home = {
    file.".oh-my-zsh-custom/themes".source = ./files/themes;
  };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      oh-my-zsh = {
        enable = true;
        # theme = "alanpeabody";
        theme = "philips"; # https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
        custom = "$HOME/.oh-my-zsh-custom";
        plugins = [
          "copyfile"
          "copypath"
          "colorize"
        ];
      };

      # dirHashes = {
      #   docs = "$HOME/Documents";
      #   vids = "$HOME/Videos";
      #   dl = "$HOME/Downloads";
      # };

      shellAliases = {
        codeium = "code";
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

        pbcopy = "xclip -selection clipboard";
        pbpaste = "xclip -selection clipboard -o";

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

      initExtra = "source ${./init.zsh}";
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

    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "ansi";
      };
    };

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
}
