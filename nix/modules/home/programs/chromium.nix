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
      package = pkgs.chromium; # extensions don't work with ungoogled version
      extensions = [
        {
          # Bitwarden
          id = "nngceckbapebfimnlniiiahkandclblb";
          version = "2026.1.1";
        }

        {
          # floccus
          id = "fnaicdffflnofjppbagibeoednhnbjhg";
          version = "5.8.6";
        }
      ];
    };
  };
}
