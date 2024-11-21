{ pkgs, ... }:

{
  # users.users.${vars.user} = { shell = pkgs.zsh; };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      oh-my-zsh = {
        enable = true;
        theme = "philips"; # https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
        custom = "$HOME/.oh-my-zsh-custom";
        plugins = [ "copyfile" "copypath" "colorize" ];
      };

      dirHashes = {
        docs = "$HOME/Documents";
        vids = "$HOME/Videos";
        dl = "$HOME/Downloads";
      };

      shellAliases = {
        reload = ". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'";
        # zshrc = "/usr/bin/code --new-window --wait ~/.zshrc && reload";

        la = "ls -Alh --group-directories-first";
        ll = "ls -lh --group-directories-first";

        sedit = "sudo -i code";
        ubuntu-version = "lsb_release -a";
        fig = "docker-compose";

        ap = "ansible-playbook";
        app =
          "ansible-playbook --ask-become-pass --extra-vars ansible_python_interpreter=/usr/bin/python3";

        myip = "curl icanhazip.com";

        pbcopy = "xclip -selection clipboard";
        pbpaste = "xclip -selection clipboard -o";
      };

      # initExtra = ''
      #   # add custom functions to fpath
      #   fpath=(~/.config/zsh/funcs $fpath);
      #   autoload -Uz $fpath[1]/*(.:t)
      # '';
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
  };
}

