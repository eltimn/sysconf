{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.services.notify;
  settings = osConfig.sysconf.settings;
in
{
  options.sysconf.services.notify = {
    enable = lib.mkEnableOption "notify";
    ntfyUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://ntfy.${settings.homeDomain}/backups";
      description = "URL for ntfy notifications.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services."notify@" = {
      Unit = {
        Description = "Send ntfy notification for %i";
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.curl}/bin/curl -H 'Title: %i' ${cfg.ntfyUrl} -d 'Error running service on %H.'";
      };
    };
  };
}
