{
  lib,
  ...
}:
{
  options.sysconf.settings = {
    timezone = lib.mkOption {
      type = lib.types.str;
      default = "America/Chicago";
      description = "System timezone.";
    };

    hostName = lib.mkOption {
      type = lib.types.str;
      description = "The hostname of the host";
    };

    deployKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBx/kbRzJWh4XIXitaJ0j8kDukQ1zWTg17XzZzdy7dCu github-actions-deploy"
      ];
      description = "SSH public keys for deployment automation (CI/CD)";
    };

    hostRole = lib.mkOption {
      type = lib.types.str;
      default = "server"; # desktop|server
      description = "Host role - determines which programs/services are enabled.";
    };

    desktopEnvironment = lib.mkOption {
      type = lib.types.str;
      default = "none"; # cosmic|gnome|none
      description = "Desktop Environment used.";
    };

    borgRepo = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "ssh://dl2juhyh@dl2juhyh.repo.borgbase.com/./repo";
      description = "Borg backup repository URL for this host.";
    };
  };
}
