{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.containers.channels-dvr;
in
{
  options.sysconf.containers.channels-dvr = {
    enable = lib.mkEnableOption "channels-dvr";
  };

  config = lib.mkIf cfg.enable {
    services.podman = {
      enable = true;

      containers = {
        "channels-dvr" = {
          image = "docker.io/fancybits/channels-dvr:latest";
          # Use host networking so that Bonjour/mDNS works properly
          network = "host";
          devices = [
            "/dev/dri:/dev/dri"
          ];
          volumes = [
            "${config.home.homeDirectory}/containers/storage/channels-dvr:/channels-dvr"
            "/mnt/channels:/shares/DVR"
          ];
          autoStart = true;
          autoUpdate = "registry";
        };
      };
    };

    # Channels DVR settings
    # Check current configuration: `systemd-tmpfiles --user --tldr`
    systemd.user.tmpfiles.rules = [
      "d ${config.home.homeDirectory}/containers/storage/channels-dvr 0770 ${config.home.username} users -"
    ];
  };
}
