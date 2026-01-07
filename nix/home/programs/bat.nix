{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.programs.bat;

  # Secure wrapper script for LESSOPEN preprocessor using bat
  # This script safely passes the filename as a literal argument to avoid shell injection
  lessopen-bat = pkgs.writeShellScriptBin "lessopen-bat" ''
    bat --paging=never --color=always "$1"
  '';
in
{
  options.sysconf.programs.bat = {
    enable = lib.mkEnableOption "bat";
  };

  config = lib.mkIf cfg.enable {
    programs.bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "ansi";
      };
    };

    home.sessionVariables = {
      LESSOPEN = "|${lessopen-bat}/bin/lessopen-bat %s"; # use bat for syntax highlighting with less (secure wrapper)
    };
  };
}
