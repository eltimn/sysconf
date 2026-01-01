{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.containers.postgresql-rz;
in
{
  options.sysconf.containers.postgresql-rz = {
    enable = lib.mkEnableOption "postgresql-rz";
  };

  config = lib.mkIf cfg.enable {
    services.podman = {
      enable = true;

      volumes = {
        "postgresql-rz-data" = { };
      };

      containers = {
        "postgresql-rz" = {
          image = "docker.io/postgres:latest";
          ports = [ "5433:5432" ];
          volumes = [
            "postgresql-rz-data:/var/lib/postgresql/data"
          ];
          autoStart = true;
          autoUpdate = "registry";
        };
      };
    };
  };
}