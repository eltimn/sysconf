{
  config,
  lib,
  pkgs-unstable,
  osConfig,
  inputs,
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

    # Symlink AI tools skills directory
    home.file.".claude/skills".source = "${inputs.eltimn-ai-tools}/skills";
  };
}
