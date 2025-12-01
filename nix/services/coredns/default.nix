{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.eltimn.services.coredns;
in
{
  options.eltimn.services.coredns = {
    enable = lib.mkEnableOption "coredns";
  };

  config = lib.mkIf cfg.enable {
    services.coredns = {
      enable = true;
      package = pkgs.coredns;
      config = (builtins.readFile ./Corefile);
    };

    environment.etc."coredns/home-eltimn-com.zone".source = ./home-eltimn-com.zone;

    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];
  };
}

# References
# https://www.caffeinatedwonders.com/2020/11/27/secure-dns-proxy/
# https://coredns.io/plugins/
