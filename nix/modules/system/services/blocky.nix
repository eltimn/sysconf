{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.services.blocky;
in
{
  options.sysconf.services.blocky = {
    enable = lib.mkEnableOption "blocky";
  };

  config = lib.mkIf cfg.enable {
    services.blocky = {
      enable = true;
      settings = {
        # Upstream DNS server configuration
        # Forward to local CoreDNS on port 5354 for local zone resolution
        upstreams = {
          groups = {
            default = [
              "127.0.0.1:5354"
            ];
          };
        };

        # Ports configuration
        ports = {
          dns = 53;
        };

        blocking = {
          denylists = {
            ads = [ "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" ];
          };
          clientGroupsBlock = {
            default = [ "ads" ];
          };
        };

        # Logging, set this to "error" to avoid collecting user info
        log = {
          level = "error";
        };
      };
    };

    # Open DNS port in firewall
    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];
  };
}
