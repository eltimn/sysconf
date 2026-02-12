{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.services.searxng;
  settings = config.sysconf.settings;
in
{
  options.sysconf.services.searxng = {
    enable = lib.mkEnableOption "searxng";
    port = lib.mkOption {
      type = lib.types.int;
      default = 8888;
      description = "The port number for the searxng service.";
    };
    environmentFile = lib.mkOption {
      type = lib.types.path;
      default = "/run/keys/searxng-env";
      description = "The path to an environment file containing SEARXNG_SECRET.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.searx = {
      enable = true;
      package = pkgs.searxng;
      redisCreateLocally = true;

      environmentFile = cfg.environmentFile;

      settings = {
        use_default_settings = true;

        general = {
          debug = false;
          instance_name = "SearXNG Home";
          enable_metrics = false;
        };

        server = {
          base_url = "https://search.${settings.homeDomain}";
          bind_address = "127.0.0.1";
          port = cfg.port;
          secret_key = "$SEARXNG_SECRET";
          limiter = false;
          public_instance = false;
          image_proxy = true;
          method = "GET";
        };

        search = {
          safe_search = 2;
          autocomplete_min = 2;
          autocomplete = "duckduckgo";
          formats = [
            "html"
            "json"
          ];
        };

        ui = {
          static_use_hash = true;
          default_locale = "en";
          query_in_title = true;
          infinite_scroll = false;
          default_theme = "simple";
        };

        outgoing = {
          request_timeout = 5.0;
          max_request_timeout = 15.0;
          enable_http2 = true;
        };

        engines = [
          {
            name = "wolframalpha";
            disabled = false;
          }
        ];
      };
    };

    # Wait for the key service before starting
    systemd.services.searx-init = lib.mkIf (cfg.environmentFile == "/run/keys/searxng-env") {
      after = [ "searxng-env-key.service" ];
      wants = [ "searxng-env-key.service" ];
    };

    services.caddy.virtualHosts = {
      "search.${settings.homeDomain}".extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
        tls { dns cloudflare {env.CF_API_TOKEN} }
      '';
    };
  };
}
