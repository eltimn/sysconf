{
  config,
  lib,
  pkgs-unstable,
  inputs,
  ...
}:
let
  cfg = config.sysconf.programs.claude;
in
{
  options.sysconf.programs.claude = {
    enable = lib.mkEnableOption "claude";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs-unstable.claude-code ];

    # Symlink unifi-gateway-api skill
    home.file.".claude/skills/unifi-gateway-api".source =
      "${inputs.eltimn-ai-tools}/skills/unifi-gateway-api";
  };
}
