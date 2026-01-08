{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.settings;
in
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

    gitEditor = lib.mkOption {
      type = lib.types.str;
      default = "nvim"; # gnome-text-editor -ns
      description = "The git editor command.";
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
  };

  # common config settings
  config = {
    # timezone
    time.timeZone = cfg.timezone;

    # networking
    networking.networkmanager.enable = true;
    networking.hostName = "${cfg.hostName}";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    # Optimization settings and garbage collection automation
    nix = {
      package = pkgs.nix-2-33;
      settings = {
        auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
    };
  };
}

# host = "ruca"
# user = "nelly"
# editor = "codium --new-window --wait"
# stow_packages = ["common", "code"]
# backup_dirs = ["Audio", "Documents", "Notes", "Pictures", "code", "secret-cipher", "sysconf"]
