{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.services.ntfy;
  settings = config.sysconf.settings;
in
{
  options.sysconf.services.ntfy = {
    enable = lib.mkEnableOption "ntfy";
    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "The port number for the ntfy service.";
    };
    baseUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://ntfy.${settings.homeDomain}";
      description = "The base URL for the ntfy service.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.ntfy-sh = {
      enable = true;
      settings = {
        listen-http = ":${toString cfg.port}";
        base-url = cfg.baseUrl;
        behind-proxy = true;
        #auth-file = "/var/lib/ntfy/user.db";
        #auth-default-access = "deny-all";
      };
    };

    services.caddy.virtualHosts."ntfy.${settings.homeDomain}".extraConfig = ''
      reverse_proxy localhost:${toString cfg.port}
      @httpget {
        protocol http
        method GET
        path_regexp ^/([-_a-z0-9]{0,64}$|docs/|static/)
      }
      redir @httpget https://{host}{uri}
      tls { dns cloudflare {env.CF_API_TOKEN} }
    '';
  };
}
