{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.containers.postgresql-test;
in
{
  options.sysconf.containers.postgresql-test = {
    enable = lib.mkEnableOption "postgresql-test";
  };

  config = lib.mkIf cfg.enable {
    services.podman = {
      enable = true;

      volumes = {
        "postgresql-test-data" = { };
      };

      containers = {
        "postgresql-test" = {
          image = "docker.io/postgres:latest";
          ports = [ "127.0.0.1:5434:5432" ];
          volumes = [
            "postgresql-test-data:/var/lib/postgresql"
          ];
          autoStart = true;
          autoUpdate = "registry";
          environment = {
            # Used on first run. Allows access without password.
            POSTGRES_HOST_AUTH_METHOD = "trust";
          };
        };
      };
    };
  };
}
