{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.services.blocky;
  dnsPort = 53;

  # # Whitelist file for domains that should never be blocked
  # whitelistFile = pkgs.writeText "blocky-whitelist.txt" ''
  #   # YouTube domains (for Premium users or to fix playback issues)
  #   youtube.com
  #   www.youtube.com
  #   googlevideo.com
  #   *.googlevideo.com
  #   youtubei.googleapis.com
  #   yt3.ggpht.com
  #   ytimg.com
  #   *.ytimg.com
  # '';
in
{
  options.sysconf.services.blocky = {
    enable = lib.mkEnableOption "blocky";

    listenAddresses = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "0.0.0.0" ];
      description = ''
        The IP addresses to bind the DNS server to.
        Default [ "0.0.0.0" ] binds to all interfaces.
        Use specific IPs (e.g., [ "10.42.10.22" "127.0.0.1" ]) to bind only
        to LAN and localhost interfaces to avoid conflicts with podman.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # When using systemd-networkd, keep systemd-resolved enabled but disable the stub listener
    # This allows systemd-resolved to manage /etc/resolv.conf and respect
    # the DNS servers configured in systemd-networkd, while freeing port 53 for blocky
    # When using NetworkManager, systemd-resolved is already disabled by default
    services.resolved = lib.mkIf config.systemd.network.enable {
      enable = true;
      # Ensure resolved never falls back to public DNS.
      fallbackDns = [ ];
      domains = [ "~home.eltimn.com" ];
      extraConfig = ''
        DNSStubListener=no
      '';
    };

    services.blocky = {
      enable = true;
      settings = {
        # Upstream DNS server configuration - use DNS-over-TLS
        upstreams = {
          groups = {
            default = [
              "tcp-tls:9.9.9.9:853" # Quad9
              "tcp-tls:1.1.1.1:853" # Cloudflare primary
              "tcp-tls:1.0.0.1:853" # Cloudflare secondary
              "tcp-tls:8.8.8.8:853" # Google primary
              "tcp-tls:8.8.4.4:853" # Google secondary
            ];
          };
          timeout = "2s";
          strategy = "parallel_best";
        };

        # Custom DNS for local zone
        customDNS = {
          zone = builtins.readFile ./home-eltimn-com.zone;
        };

        # Conditional forwarding for ACME challenges
        # Bypass local DNS so Caddy can use public DNS for DNS-01 challenges
        conditional = {
          fallbackUpstream = false;
          mapping = {
            "_acme-challenge.home.eltimn.com" = "1.1.1.1";
          };
        };

        # Ports configuration - bind to all specified addresses
        ports = {
          dns = map (addr: "${addr}:${toString dnsPort}") cfg.listenAddresses;
        };

        blocking = {
          denylists = {
            ads = [ "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" ];
          };
          clientGroupsBlock = {
            default = [ "ads" ];
          };
          # Whitelist for domains that should never be blocked
          # allowlists = {
          #   ads = [ "${whitelistFile}" ];
          # };
        };

        # Caching configuration
        caching = {
          minTime = "5m";
          maxTime = "30m";
          prefetching = true;
          prefetchExpires = "2h";
          prefetchThreshold = 5;
        };

        # Logging, set this to "error" to avoid collecting user info
        log = {
          level = "error";
        };
      };
    };

    # Ensure blocky starts after systemd-resolved is ready for DNS resolution
    # (needed to download blocklists at startup)
    systemd.services.blocky = {
      after = [ "systemd-resolved.service" ];
      wants = [ "systemd-resolved.service" ];
    };

    # Open DNS port in firewall
    networking.firewall.allowedTCPPorts = [ dnsPort ];
    networking.firewall.allowedUDPPorts = [ dnsPort ];
  };
}
