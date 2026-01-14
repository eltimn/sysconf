{
  config,
  pkgs,
  ...
}:
{

  imports = [
    ../../modules/home/desktop
  ];

  # these are mainly for opentofu
  sops.secrets."cloudflare_api_token" = { };
  sops.secrets."do_access_token" = { };
  sops.secrets."do_images_key" = { };
  sops.secrets."do_spaces_key" = { };

  # git secrets
  sops.secrets."git/github" = { };
  sops.secrets."git/user" = { };

  home = {
    username = "nelly";
    homeDirectory = "/home/nelly";
    stateVersion = "24.11";

    # Packages that should be installed to the user profile.
    packages = with pkgs; [
      crush
      gemini-cli
      unifi-api

    ];

    # List of extra paths to include in the user profile.
    sessionPath = [
      "$HOME/bin"
      "$HOME/bin/common"
      "$HOME/bin/desktop"
      "$HOME/go/bin"
      "$HOME/.local/bin"
    ];

    # List of environment variables.
    sessionVariables = {
      EDITOR = "zeditor --wait"; # osConfig.sysconf.users.nelly.envEditor;
      VISUAL = "zeditor --wait";
      COSMIC_DATA_CONTROL_ENABLED = 1;
    };

    # some files
    file.".config/borg/backup_dirs".text =
      "export BACKUP_DIRS='Audio Documents Notes Pictures code secret-cipher sysconf'";
    # autostart files (run on login)
    file.".config/autostart/filen.desktop".source = ./files/filen.desktop;
    # file.".config/autostart/mount-secret.desktop".source = ./files/mount-secret.desktop;
  };

  # Packages that are installed as programs also allow for configuration.
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";
    };
  };

  # Enable sysconf modules
  sysconf = {
    desktop.cosmic.primaryMonitor = "HDMI-A-1";

    containers.mongodb-rz.enable = true;
    containers.postgresql-rz.enable = true;

    programs = {
      claude.enable = true;
      nodejs.enable = true;

      git = {
        githubIncludePath = config.sops.secrets."git/github".path;
        userIncludePath = config.sops.secrets."git/user".path;
      };
    };

    services.notify.enable = true;
  };

  # Systemd user services
  systemd.user = {
    enable = true;

    # Set PATH for all systemd user services
    sessionVariables = {
      PATH = "/run/current-system/sw/bin";
    };

    # systemctl --user status backup-XXX.timer
    # systemctl --user status backup-XXX.service
    # journalctl --user -u backup-XXX -f # follows
    # journalctl --user -xeu backup-XXX # pages down to end and adds more info
    services = {
      # backup-borg = {
      #   Unit = {
      #     Description = "Backup computer files using borg.";
      #     Requires = "backup-borg.timer";
      #     OnFailure = "notify@%i.service";
      #   };
      #   Service = {
      #     Type = "simple";
      #     ExecStart = "${config.home.homeDirectory}/bin/desktop/backup-borg";
      #   };
      # };

      mount-secret = {
        Unit = {
          Description = "Mount encrypted secret directory with gocryptfs";
          After = "xdg-desktop-autostart.target";
        };
        Service = {
          Type = "exec";
          Environment = "PATH=/run/wrappers/bin:${pkgs.gocryptfs}/bin:${pkgs.libsecret}/bin";
          ExecStart = "${pkgs.gocryptfs}/bin/gocryptfs -fg --extpass='${pkgs.libsecret}/bin/secret-tool lookup gocryptfs secret' ${config.home.homeDirectory}/secret-cipher ${config.home.homeDirectory}/secret";
          ExecStop = "/run/wrappers/bin/fusermount -u ${config.home.homeDirectory}/secret";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };

      backup-secrets = {
        Unit = {
          Description = "Backup secret files.";
          Requires = "backup-secrets.timer";
          OnFailure = "notify@%i.service";
        };
        Service = {
          Type = "simple";
          ExecStart = "${config.home.homeDirectory}/bin/desktop/backup-secrets";
        };
      };

      backup-workstation = {
        Unit = {
          Description = "Backup workstation files.";
          Requires = "backup-workstation.timer";
          OnFailure = "notify@%i.service";
        };
        Service = {
          Type = "simple";
          Environment = "SSH_AUTH_SOCK=%t/gcr/ssh";
          ExecStart = "${config.home.homeDirectory}/bin/desktop/backup-workstation";
        };
      };
    };

    # OnStartupSec - Triggers the service to run this amount of time after login, since this is a user service.
    # OnUnitActiveSec - Triggers the service to run this amount of time after the last execution ("last activated").
    timers = {
      # backup-borg = {
      #   Unit = {
      #     Description = "Timer for the backup-borg.service";
      #   };

      #   Timer = {
      #     Unit = "backup-borg.service";
      #     OnCalendar = "*-*-* 18:00:00"; # daily at 6:00 PM
      #   };

      #   Install = {
      #     WantedBy = [ "timers.target" ];
      #   };
      # };

      backup-secrets = {
        Unit = {
          Description = "Timer for the backup-secrets.service";
        };

        Timer = {
          Unit = "backup-secrets.service";
          OnStartupSec = "3min";
          OnUnitActiveSec = "20min";
        };

        Install = {
          WantedBy = [ "timers.target" ];
        };
      };

      backup-workstation = {
        Unit = {
          Description = "Timer for the backup-workstation.service";
        };

        Timer = {
          Unit = "backup-workstation.service";
          OnStartupSec = "5min";
          OnUnitActiveSec = "20min";
        };

        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
  };
}
