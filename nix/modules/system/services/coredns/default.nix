{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.services.coredns;
  zoneFile = ./home-eltimn-com.zone;
in
{
  options.sysconf.services.coredns = {
    enable = lib.mkEnableOption "coredns";
  };

  config = lib.mkIf cfg.enable {
    services.coredns = {
      enable = true;
      package = pkgs.coredns;
      config = builtins.readFile ./Corefile;
    };

    environment.etc."coredns/home-eltimn-com.zone".source = zoneFile;

    # Reload CoreDNS when zone file changes
    systemd.services.coredns = {
      reloadTriggers = [ zoneFile ];
    };
  };
}

# References
# https://www.caffeinatedwonders.com/2020/11/27/secure-dns-proxy/
# https://coredns.io/plugins/
