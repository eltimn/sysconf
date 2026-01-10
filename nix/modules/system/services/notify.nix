{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.services.notify;
  settings = config.sysconf.settings;
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
    # System-level notification service template
    # @ means it's a template that accepts a single parameter
    # e.g. systemctl start notify@forgejo-backup.service
    systemd.services."notify@" = {
      description = "Send ntfy notification for %i";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.curl}/bin/curl -H 'Title: %i' ${cfg.ntfyUrl} -d 'Error running service on %H.'";
      };
    };
  };
}
