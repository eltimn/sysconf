{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.programs.yazi;

  # `nurl https://github.com/yazi-rs/plugins 196281844b8cbcac658a59013e4805300c2d6126`
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "196281844b8cbcac658a59013e4805300c2d6126";
    hash = "sha256-pAkBlodci4Yf+CTjhGuNtgLOTMNquty7xP0/HSeoLzE=";
  };
in
{
  options.sysconf.programs.yazi = {
    enable = lib.mkEnableOption "yazi";
  };

  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";
      settings = {
        mgr = {
          sort_dir_first = true;
        };
      };

      plugins = {
        chmod = "${yazi-plugins}/chmod.yazi";
        full-border = "${yazi-plugins}/full-border.yazi";
        toggle-pane = "${yazi-plugins}/toggle-pane.yazi";
      };

      initLua = ''
        require("full-border"):setup()
      '';
    };
  };
}
