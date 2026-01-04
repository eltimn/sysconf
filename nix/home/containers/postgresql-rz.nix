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
            "postgresql-rz-data:/var/lib/postgresql"
          ];
          autoStart = true;
          autoUpdate = "registry";
          environment = {
            # These only matter on first run. It was initialized with the password.
            # POSTGRES_PASSWORD = "not-secret";
            # POSTGRES_HOST_AUTH_METHOD = "trust";
          };
        };
      };
    };
  };
}
