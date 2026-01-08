# Direnv
{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.programs.direnv;
in
{
  options.sysconf.programs.direnv = {
    enable = lib.mkEnableOption "direnv";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      # enableZshIntegration = true;
      # loadInNixShell = true;
      nix-direnv.enable = true;
    };
  };
}
