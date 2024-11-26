{ pkgs, ... }:

{
  home = {
    file.".config/git/extra.inc".source = ./files/extra.inc;
  };

  programs.git = {
    enable = true;
    aliases = {
      au = "add -u .";
      br = "branch";
      ci = "commit";
      cia = "commit --amend";
      co = "checkout";
      df = "diff"; # difftastic
      dff = "diff --no-ext-diff"; # plain diff
      dfm = "difftool --tool=meld"; # meld
      dft = "difftool"; # codium
      st = "status";
      cleanup =
        "!git branch --merged main | grep -v '^*\\|main' | xargs -r -n 1 git branch -D";
      remove = "git rm --cached";
      lg = "log --pretty='tformat:%h %an (%ai): %s' --topo-order --graph";
      lgg = "log --pretty='tformat:%h %an (%ai): %s' --topo-order --graph --grep";
    };

    # diff.external makes it the default when calling `git diff`.

    # Creates the following in git config file
    # [diff]
    #   external = "/nix/store/cik2nqbvkjr01zmvxm2i2iz1fzplpyzs-difftastic-0.56.1/bin/difft --color auto --background light --display side-by-side"
    difftastic.enable = true;

    extraConfig = {
      diff = {
        tool = "codium";
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
    ];
    includes = [
      { path = "extra.inc"; }
      { path = "gitconfig.d/github.inc"; }
      { path = "gitconfig.d/user.inc"; }
    ];
  };
}