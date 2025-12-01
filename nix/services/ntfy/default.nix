{
  config,
  lib,
  ...
}:
let
  cfg = config.eltimn.services.ntfy;
in
{
  options.eltimn.services.ntfy = {
    enable = lib.mkEnableOption "ntfy";
    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "The port number for the ntfy service.";
    };
    baseUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://ntfy.local";
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
  };
}
