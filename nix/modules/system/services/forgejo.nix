{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.services.forgejo;
  srv = config.services.forgejo.settings.server;
in
{
  options.sysconf.services.forgejo = {
    enable = lib.mkEnableOption "forgejo";
    port = lib.mkOption {
      type = lib.types.number;
      description = "The port Forgejo runs on.";
      default = 3000;
    };
  };

  config = lib.mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      settings = {
        session.COOKIE_SECURE = true;
        server = {
          HTTP_PORT = cfg.port;
          HTTP_ADDR = "127.0.0.1";
          DOMAIN = "git.home.eltimn.com";
          # You need to specify this to remove the port from URLs in the web UI.
          ROOT_URL = "https://${srv.DOMAIN}/";
          SSH_PORT = lib.head config.services.openssh.ports; # for using ssh with git
        };

        database = {
          type = "sqlite3";
          SQLITE_JOURNAL_MODE = "WAL";
        };

        service.DISABLE_REGISTRATION = true;

        security.LOGIN_REMEMBER_DAYS = 365;
      };
    };

    sysconf.services.caddy.virtualHosts.git = ''
      reverse_proxy localhost:${toString cfg.port}
    '';
  };
}
