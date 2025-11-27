{ pkgs, ... }:

{
  services.coredns = {
    enable = true;
    package = pkgs.coredns;
    config = (builtins.readFile ./Corefile);
  };

  environment.etc."coredns/home-eltimn-com.zone".source = ./home-eltimn-com.zone;
}

# References
# https://www.caffeinatedwonders.com/2020/11/27/secure-dns-proxy/
# https://coredns.io/plugins/
