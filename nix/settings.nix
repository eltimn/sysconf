{ config, lib, ... }:

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

    primaryUsername = lib.mkOption {
      type = lib.types.str;
      default = "nelly";
      description = "The primary administrative username of the host";
    };

    primaryUserSshKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "A list of SSH public keys to install for the primary user.";
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILKlXvCa8D1VqasrHkgsnajPhaUA5N2pJ0b9OASPqYij tim@lappy"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXS57Mn5Hsbkyv/byapcmgEVkRKqEnudWaCSDmpkRdb nelly@ruca"
      ];
    };
  };

  # common config settings
  config = {
    # timezone
    time.timeZone = config.sysconf.settings.timezone;

    # networking
    networking.networkmanager.enable = true;
    networking.hostName = "${config.sysconf.settings.hostName}";

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
  };
}

# host = "ruca"
# user = "nelly"
# editor = "codium --new-window --wait"
# stow_packages = ["common", "code"]
# backup_dirs = ["Audio", "Documents", "Notes", "Pictures", "code", "secret-cipher", "sysconf"]
