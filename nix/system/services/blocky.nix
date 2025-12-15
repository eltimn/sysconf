{ ... }:

{
  services.blocky = {
    enable = true;
    settings = {
      # Upstream DNS server configuration
      upstream = {
        default = [
          # Modify these default DNS servers to your liking
          "9.9.9.9"
          "tcp-tls:fdns1.dismail.de:853"
          "https://dns.digitale-gesellschaft.ch/dns-query"
        ];
      };

      # Ports configuration
      ports = {
        dns = 53;
        http = 4000;
        tls = 853;
      };

      # Logging, set this to "error" to avoid collecting user info
      log = {
        level = "info";
      };

      customDNS = {
        customTTL = "1h";
        mapping = {
          "ruca.home.eltimn.com" = "192.168.1.163";
          "illmatic.home.eltimn.com" = "192.168.1.50";
          "cbox.home.eltimn.com" = "192.168.1.158";

          "dvr.home.eltimn.com" = "illmatic.home.eltimn.com";
          "plex.home.eltimn.com" = "illmatic.home.eltimn.com";
          "unifi.home.eltimn.com" = "illmatic.home.eltimn.com";
          "www.home.eltimn.com" = "illmatic.home.eltimn.com";
          "ntfy.home.eltimn.com" = "illmatic.home.eltimn.com";
          "router.home.eltimn.com" = "illmatic.home.eltimn.com";
          "jfin.home.eltimn.com" = "ruca.home.eltimn.com";
        };
      };
    };
  };
}
