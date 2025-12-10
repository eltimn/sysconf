{ config, lib, ... }:
let
  cfg = config.sysconf.services.opencloud;
in
{
  options.sysconf.services.opencloud = {
    enable = lib.mkEnableOption "opencloud";
    port = lib.mkOption {
      type = lib.types.int;
      default = 9200;
      description = "The port number for the opencloud service.";
    };
    baseUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://cloud.local";
      description = "The base URL for the opencloud service.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.opencloud = {
      enable = true;
      url = cfg.baseUrl;
      port = cfg.port;
    };
  };
}
