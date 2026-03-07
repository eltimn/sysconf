{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.programs.yazi;
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
        chmod = pkgs.yaziPlugins.chmod;
        full-border = pkgs.yaziPlugins.full-border;
        toggle-pane = pkgs.yaziPlugins.toggle-pane;
        mount = pkgs.yaziPlugins.mount;
      };

      keymap = {
        mgr.prepend_keymap = [
          {
            on = "M";
            run = "plugin mount";
          }
        ];
      };

      initLua = ''
        require("full-border"):setup()
      '';
    };
  };
}
