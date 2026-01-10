{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.services.immich;
  settings = config.sysconf.settings;
in
{
  options.sysconf.services.immich = {
    enable = lib.mkEnableOption "immich";
    port = lib.mkOption {
      type = lib.types.int;
      default = 2283;
      description = "The port number for the immich service.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      port = cfg.port;
    };

    services.caddy.virtualHosts."pics.${settings.homeDomain}".extraConfig = ''
      reverse_proxy localhost:${toString cfg.port}
      tls { dns cloudflare {env.CF_API_TOKEN} }
    '';
  };
}
