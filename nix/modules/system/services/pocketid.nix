{
  config,
  inputs,
  lib,
  pkgs-unstable,
  ...
}:
let
  cfg = config.sysconf.services.pocketid;
  settings = config.sysconf.settings;
in
{
  # 1. Disable the stable module
  disabledModules = [ "services/security/pocket-id.nix" ];
  # 2. Import the unstable module
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/security/pocket-id.nix"
  ];

  options.sysconf.services.pocketid = {
    enable = lib.mkEnableOption "pocketid";
    port = lib.mkOption {
      type = lib.types.int;
      default = 8086;
      description = "The port number for the pocketid service.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.pocket-id = {
      enable = true;
      package = pkgs-unstable.pocket-id;
      settings = {
        APP_URL = "https://id.${settings.homeDomain}";
        PORT = cfg.port;
        TRUST_PROXY = true;
        ANALYTICS_DISABLED = true;
      };
      credentials = {
        ENCRYPTION_KEY = "/run/keys/pocketid-encryption-key";
      };
    };

    services.caddy.virtualHosts = {
      "id.${settings.homeDomain}".extraConfig = ''
        reverse_proxy localhost:${toString cfg.port}
        tls { dns cloudflare {env.CF_API_TOKEN} }
      '';
    };
  };
}
