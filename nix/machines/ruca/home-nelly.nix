{
  config,
  osConfig,
  pkgs,
  ...
}:
{

  imports = [
    ../../modules/home/desktop
  ];

  sysconf.settings.secretCipherPath = "/srv/ext/nelly/secret-cipher";

  # git secrets
  sops.secrets = {
    "git/github" = { };
    "git/user" = { };
    "borg_passphrase_illmatic" = { };
  };

  home = {
    username = "nelly";
    homeDirectory = "/home/nelly";
    stateVersion = "24.11";

    # Packages that should be installed to the user profile.
    packages = with pkgs; [
      gemini-cli
      unifi-api
    ];

    # List of extra paths to include in the user profile.
    sessionPath = [
      "$HOME/bin"
      "$HOME/go/bin"
      "$HOME/.local/bin"
    ];

    # List of environment variables.
    sessionVariables = {
      EDITOR = osConfig.sysconf.users.nelly.envEditor;
      VISUAL = osConfig.sysconf.users.nelly.envEditor;
      COSMIC_DATA_CONTROL_ENABLED = 1;
    };

    # some files
    file.".config/borg/backup_dirs".text =
      "export BACKUP_DIRS='Audio Documents Notes Pictures code sysconf'";
    # autostart files (run on login)
    file.".config/autostart/filen.desktop".source = ./files/filen.desktop;
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
    # desktop.niri.leftHandedMouse = true;
    desktop.niri.extraConfig = ''
      // https://yalter.github.io/niri/Configuration:-Input
      input {
        keyboard {
          xkb {
            // You can set rules, model, layout, variant and options.
            // For more information, see xkeyboard-config(7).

            // For example:
            // layout "us,ru"
            // options "grp:win_space_toggle,compose:ralt,ctrl:nocaps"

            // If this section is empty, niri will fetch xkb settings
            // from org.freedesktop.locale1. You can control these using
            // localectl set-x11-keymap.
          }

          // Enable numlock on startup, omitting this setting disables it.
          numlock
        }

        // Next sections include libinput settings.
        // Omitting settings disables them, or leaves them at their default values.
        // All commented-out settings here are examples, not defaults.
        touchpad {
          off
          //tap
          // dwt
          // dwtp
          // drag false
          // drag-lock
          //natural-scroll
          // accel-speed 0.2
          // accel-profile "flat"
          // scroll-method "two-finger"
          // disabled-on-external-mouse
        }

        mouse {
          // off
          // natural-scroll
          // accel-speed 0.2
          // accel-profile "flat"
          // scroll-method "no-scroll"
          left-handed
        }

        trackpoint {
          off
          // natural-scroll
          // accel-speed 0.2
          // accel-profile "flat"
          // scroll-method "on-button-down"
          // scroll-button 273
          // scroll-button-lock
          // middle-emulation
        }

        // Uncomment this to make the mouse warp to the center of newly focused windows.
        // warp-mouse-to-focus

        // Focus windows and outputs automatically when moving the mouse into them.
        // Setting max-scroll-amount="0%" makes it work only on windows already fully on screen.
        // focus-follows-mouse max-scroll-amount="0%"
      }

      // Monitor configuration
      // Samsung (main) on the left, Dell on the right
      output "HDMI-A-1" {
        position x=0 y=0
        focus-at-startup
      }

      output "DP-2" {
        position x=2560 y=0
      }
    '';

    containers.mongodb-rz.enable = true;
    containers.postgresql-rz.enable = true;

    programs = {
      claude.enable = true;
      nodejs.enable = true;

      git = {
        githubIncludePath = config.sops.secrets."git/github".path;
        userIncludePath = config.sops.secrets."git/user".path;
      };

      zen-browser = {
        enable = true;
        profileName = "nelly";
      };
    };

    services.notify.enable = true;
  };

  # Systemd user services
  systemd.user = {
    enable = true;

    tmpfiles.rules = [
      "d ${config.sysconf.settings.secretCipherPath} 0700 - - -"
      "d ${config.home.homeDirectory}/secret 0700 - - -"
      # Filen sync directories
      "d ${config.home.homeDirectory}/Audio 0750 - - -"
      "d ${config.home.homeDirectory}/Documents 0700 - - -"
      "d ${config.home.homeDirectory}/Notes 0700 - - -"
    ];

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
      #     ExecStart = "${config.home.homeDirectory}/bin/backup-borg";
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
          ExecStart = "${pkgs.gocryptfs}/bin/gocryptfs -fg --extpass='${pkgs.libsecret}/bin/secret-tool lookup gocryptfs secret' ${config.sysconf.settings.secretCipherPath} ${config.home.homeDirectory}/secret";
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
          ExecStart = "${config.home.homeDirectory}/bin/backup-secrets";
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
          ExecStart = "${config.home.homeDirectory}/bin/backup-workstation";
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
