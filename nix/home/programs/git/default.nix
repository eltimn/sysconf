{ pkgs, ... }:

{
  home = {
    file.".config/git/extra.inc".source = ./files/extra.inc;
  };

  programs.git = {
    enable = true;
    aliases = {
      au = "add -u ."; # add all files that are already being tracked
      br = "branch";
      ci = "commit";
      cia = "commit --amend";
      co = "checkout";
      df = "diff"; # external (difftastic)
      dff = "diff --no-ext-diff"; # plain diff
      dfm = "difftool --tool=meld"; # meld
      dfc = "difftool"; # codium
      st = "status";
      sw = "switch";
      cleanup = "!git branch --merged main | grep -v '^*\\|main' | xargs -r -n 1 git branch -D";
      prune = "fetch --prune origin";
      remove = "rm --cached";
      lg = "log --pretty='tformat:%h %an (%ai): %s' --topo-order --graph";
      lgg = "log --pretty='tformat:%h %an (%ai): %s' --topo-order --graph --grep";
    };

    # diff.external makes it the default when calling `git diff`.

    # Creates the following in git config file
    # [diff]
    #   external = "/nix/store/cik2nqbvkjr01zmvxm2i2iz1fzplpyzs-difftastic-0.56.1/bin/difft --color auto --background light --display side-by-side"
    difftastic.enable = true;

    extraConfig = {
      core = {
        editor = "nvim";
      };

      diff = {
        tool = "codium";
        # external = "difft --color auto --background light --display side-by-side";
      };

      difftool = {
        prompt = false;
        codium = {
          cmd = "${pkgs.vscodium}/bin/codium --wait --new-window --diff $LOCAL $REMOTE";
        };
      };
    };

    ignores = [
      "*.com"
      "*.class"
      "*.dll"
      "*.exe"
      "*.o"
      "*.so"
      "*.pyc"
      "*.7z"
      "*.dmg"
      "*.gz"
      "*.iso"
      "*.jar"
      "*.rar"
      "*.tar"
      "*.zip"
      "*.log"
      "*.sql"
      "*.sqlite"
      ".DS_Store?"
      "ehthumbs.db"
      "Icon?"
      "Thumbs.db"
      ".hg/"
      ".hgignore"
      "*.sublime-project"
      "*.sublime-workspace"
      ".svn/"
      ".direnv/"
      ".envrc"
    ];
    includes = [
      { path = "extra.inc"; }
      { path = "gitconfig.d/github.inc"; }
      { path = "gitconfig.d/user.inc"; }
    ];
  };
}
