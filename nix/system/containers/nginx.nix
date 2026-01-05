# Nginx container using the rootless container module
#
# Managing the service:
#   machinectl shell nginx@ /run/current-system/sw/bin/bash
#   systemctl --user status nginx
#   journalctl --user -eu nginx
# Or:
#   sudo -u nginx XDG_RUNTIME_DIR=/run/user/990 systemctl --user status nginx
#   sudo -u nginx XDG_RUNTIME_DIR=/run/user/990 journalctl --user -eu nginx
{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.containers.nginx;
in
{
  options.sysconf.containers.nginx = {
    enable = lib.mkEnableOption "nginx";
  };

  config = lib.mkIf cfg.enable {
    sysconf.rootlessContainers = {
      enable = true;

      users.nginx = {
        uid = 940;
        group = "users";
        createGroup = false;

        containers.nginx = {
          description = "Nginx Container";
          image = "docker.io/library/nginx:latest";
          ports = [
            "8080:80"
            "8443:443"
          ];
          volumes = [
            "/var/lib/nginx/html:/usr/share/nginx/html"
            "/var/lib/nginx/conf:/etc/nginx/conf.d"
          ];
        };
      };
    };

    # Firewall rules for Nginx
    networking.firewall.allowedTCPPorts = [
      8080 # HTTP
      8443 # HTTPS
    ];

    # Storage directories
    systemd.tmpfiles.rules = [
      "d /var/lib/nginx/html 0755 nginx users -"
      "d /var/lib/nginx/conf 0755 nginx users -"
    ];
  };
}
