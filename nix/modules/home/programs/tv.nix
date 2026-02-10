{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.programs.tv;
in
{
  options.sysconf.programs.tv = {
    enable = lib.mkEnableOption "tv";
  };

  config = lib.mkIf cfg.enable {
    # Settings: https://github.com/alexpasmantier/television/blob/main/.config/config.toml
    programs.television = {
      enable = true;
      enableZshIntegration = true;
    };

    # Configuration: https://github.com/3timeslazy/nix-search-tv?tab=readme-ov-file#configuration
    programs.nix-search-tv = {
      enable = true;
      enableTelevisionIntegration = true;
    };
  };
}
