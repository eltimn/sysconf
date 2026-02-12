{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.programs.chromium;
in
{
  options.sysconf.programs.chromium = {
    enable = lib.mkEnableOption "chromium";
  };

  config = lib.mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      extensions = [
        {
          # Bitwarden
          id = "nngceckbapebfimnlniiiahkandclblb";
          version = "2026.1.0";
        }
      ];
    };
  };
}
