{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.services.forgejo;
  srv = config.services.forgejo.settings.server;
  settings = config.sysconf.settings;
in
{
  options.sysconf.services.forgejo = {
    enable = lib.mkEnableOption "forgejo";
    port = lib.mkOption {
      type = lib.types.port;
      description = "The port Forgejo runs on.";
      default = 3000;
    };
  };

  config = lib.mkIf cfg.enable {
    # Add forgejo user to keys group for secrets access
    users.users.forgejo.extraGroups = [ "keys" ];

    # Create SSH directory and key for forgejo user (for borg backups)
    systemd.tmpfiles.rules = [
      "d /var/lib/forgejo/.ssh 0700 forgejo forgejo -"
    ];

    # Generate SSH key for forgejo user if it doesn't exist
    system.activationScripts.forgejo-ssh-key = {
      deps = [ "users" ];
      text = ''
        if [ ! -f /var/lib/forgejo/.ssh/id_ed25519 ]; then
          ${lib.getExe' config.systemd.package "systemd-run"} --unit=forgejo-ssh-keygen --uid=forgejo --gid=forgejo \
            ${lib.getExe' config.programs.ssh.package "ssh-keygen"} -t ed25519 -f /var/lib/forgejo/.ssh/id_ed25519 -N "" -C "forgejo@${config.networking.hostName}"
        fi
      '';
    };

    services.forgejo = {
      enable = true;
      settings = {
        server = {
          HTTP_PORT = cfg.port;
          HTTP_ADDR = "127.0.0.1";
          DOMAIN = "git.${settings.homeDomain}";
          # You need to specify this to remove the port from URLs in the web UI.
          ROOT_URL = "https://${srv.DOMAIN}/";
          SSH_PORT = lib.head config.services.openssh.ports; # for using ssh with git
        };

        database = {
          type = "sqlite3";
          SQLITE_JOURNAL_MODE = "WAL";
        };

        security.LOGIN_REMEMBER_DAYS = 365;
        service.DISABLE_REGISTRATION = true;
        session.COOKIE_SECURE = true;
      };
    };

    services.caddy.virtualHosts."git.${settings.homeDomain}".extraConfig = ''
      reverse_proxy localhost:${toString cfg.port}
      tls { dns cloudflare {env.CF_API_TOKEN} }
    '';
  };
}
