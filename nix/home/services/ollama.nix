{
  config,
  lib,
  pkgs-unstable,
  ...
}:
let
  cfg = config.sysconf.home.services.ollama;
in
{
  options.sysconf.home.services.ollama = {
    enable = lib.mkEnableOption "ollama";
    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "The port number for the ollama service.";
    };
    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "The host address for the ollama service.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = pkgs-unstable.ollama;
      port = cfg.port;
      host = cfg.host;

      # Optional extra flags – for example, enable verbose logging:
      # extraOptions = [ "--verbose" ];

      # Optional environment variables
      # environment = { OLLAMA_DEBUG = "1"; };

      # If you need to tweak systemd directly, use serviceConfig:
      # serviceConfig = {
      #   MemoryLimit = "2G";
      #   CPUQuota    = "80%";
      # };
    };
  };
}
