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
