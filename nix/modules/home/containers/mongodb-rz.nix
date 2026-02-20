{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.containers.mongodb-rz;
in
{
  options.sysconf.containers.mongodb-rz = {
    enable = lib.mkEnableOption "mongodb-rz";
  };

  config = lib.mkIf cfg.enable {
    services.podman = {
      enable = true;

      volumes = {
        "mongodb-rz-data" = { };
      };

      containers = {
        "mongodb-rz" = {
          image = "docker.io/mongodb/mongodb-community-server:latest";
          ports = [ "127.0.0.1:2700:27017" ];
          volumes = [
            "mongodb-rz-data:/data/db"
          ];
          autoStart = true;
          autoUpdate = "registry";
        };
      };
    };
  };
}
