{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.swappy;
in
{
  options.sysconf.desktop.swappy = {
    enable = lib.mkEnableOption "swappy";

    screenshotsPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/Screenshots";
      description = "Directory where screenshots taken by swappy will be saved.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      swappy
    ];

    # https://github.com/jtheoof/swappy?tab=readme-ov-file#config
    xdg.configFile."swappy/config".text = ''
      [Default]
      save_dir=${cfg.screenshotsPath}
      save_filename_format=screenshot-%Y%m%d-%H%M%S.png
    '';

    systemd.user.tmpfiles.rules = [ "d ${cfg.screenshotsPath} 0755 - - -" ];
  };
}
