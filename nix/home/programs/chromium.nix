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
          version = "2025.12.0";
        }
        {
          # Grammarly
          id = "kbfnbcaeplbcioakkpcpgfkobkghlhen";
          version = "14.1267.0";
        }
        {
          # Start page
          id = "fgmjlmbojbkmdpofahffgcpkhkngfpef";
          version = "3.0.8";
        }
      ];
    };
  };
}
