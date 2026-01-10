{
  config,
  lib,
  pkgs-unstable,
  osConfig,
  ...
}:
let
  cfg = config.sysconf.programs.claude;
  settings = osConfig.sysconf.settings;
in
{
  options.sysconf.programs.claude = {
    enable = lib.mkEnableOption "claude";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs-unstable.claude-code ];
  };
}
