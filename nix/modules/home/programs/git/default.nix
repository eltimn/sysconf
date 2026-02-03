{
  config,
  lib,
  osConfig,
  ...
}:
let
  cfg = config.sysconf.programs.git;
in
{
  options.sysconf.programs.git = {
    enable = lib.mkEnableOption "git";

    githubIncludePath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to github git config include file";
    };

    userIncludePath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to user git config include file";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/git/extra.inc".source = ./files/extra.inc;

    programs = {
      difftastic = {
        enable = true;
        git.enable = true;
      };

      lazygit.enable = true;

      git = {
        enable = true;

        settings = {
          alias = {
            au = "add -u ."; # add all files that are already being tracked
            br = "branch";
            ci = "commit";
            cia = "commit --amend";
            co = "checkout";
            df = "diff"; # external (difftastic)
            dfl = "diff HEAD~1"; # diff last commit
            dff = "diff --no-ext-diff"; # plain diff
            dfm = "difftool --tool=meld"; # meld
            dft = "difftool";
            dfz = "difftool --tool=zed";
            st = "status";
            sw = "switch";
            cleanup = "!git branch --merged main | grep -v '^*\\|main' | xargs -r -n 1 git branch -D";
            prune = "fetch --prune origin"; # git remote update origin --prune (are these the same ???)
            remove = "rm --cached";
            lg = "log --pretty='tformat:%h %an (%ai): %s' --topo-order --graph";
            lgg = "log --pretty='tformat:%h %an (%ai): %s' --topo-order --graph --grep";
          };

          core = {
            editor = osConfig.sysconf.users.nelly.gitEditor;
          };

          diff = {
            tool = "zed";
            # external = "difft --color auto --background light --display side-by-side";
          };

          difftool = {
            prompt = false;
            codeium = {
              cmd = "codium --wait --new-window --diff \"$LOCAL\" \"$REMOTE\"";
            };
            zed = {
              cmd = "zeditor --wait --diff \"$LOCAL\" \"$REMOTE\"";
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
        ];
        includes = [
          { path = "extra.inc"; }
        ]
        ++ lib.optionals (cfg.githubIncludePath != null) [
          { path = cfg.githubIncludePath; }
        ]
        ++ lib.optionals (cfg.userIncludePath != null) [
          { path = cfg.userIncludePath; }
        ];
      };
    };
  };
}
