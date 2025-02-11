{
  config,
  pkgs,
  vars,
  ...
}:
let
  filen-desktop = (pkgs.callPackage ../../home/pkgs/filen-desktop.nix { });
in
{

  imports = [
    ../../home/common
    ../../home/desktop
    ../../home/programs/git
    ../../home/programs/vscode
    ../../home/programs/zsh
    ../../home/programs/direnv.nix
    ../../home/programs/tmux.nix
  ];

  # fonts.fontconfig.enable = true;
  # xdg.mime.enable = false; # fixes a bug where nautilus crashes

  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "${vars.user}";
    homeDirectory = "/home/${vars.user}";
    stateVersion = "24.11";

    # Packages that should be installed to the user profile.
    packages = with pkgs; [
      btop
      dust # better `du`
      fastfetch
      fd
      gnome-terminal
      gocryptfs
      gum
      shellcheck
      # fd
      filen-desktop
      firefox
      gnomeExtensions.appindicator
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.dash-to-dock
      gnumake
      lm_sensors
      nushell
      ollama
      # parcellite
      # sqlitebrowser
      stow
      # vivaldi
      # vivaldi-ffmpeg-codecs
      wezterm
      zen-browser
    ];

    # List of extra paths to include in the user profile.
    sessionPath = [
      "$HOME/bin"
      "$HOME/bin/common"
      "$HOME/bin/desktop"
      "$HOME/go/bin"
    ];

    # List of environment variables.
    sessionVariables = {
      EDITOR = "${vars.editor}";
      # JAVA_HOME = "/usr/lib/jvm/java-17-openjdk-amd64";
    };

    # some files
    file.".config/borg/backup_dirs".text =
      "export BACKUP_DIRS='${builtins.concatStringsSep " " vars.backup_dirs}'";
    file.".config/autostart/filen.desktop".source = ./files/filen.desktop;
    file.".config/autostart/mount-secret.desktop".source = ./files/mount-secret.desktop;
  };

  # Packages that are installed as programs also allow for configuration.
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    lazygit.enable = true;

    yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";
    };

    # ghostty doesn't work with current ruca hardware
    # (ghostty:80405): Gtk-WARNING **: 20:23:38.051: No IM module matching GTK_IM_MODULE=ibus found
    # error(gtk_surface): surface failed to realize: Failed to create EGL display
    # warning(gtk_surface): this error is usually due to a driver or gtk bug
    # warning(gtk_surface): this is a common cause of this issue: https://gitlab.gnome.org/GNOME/gtk/-/issues/4950
    ghostty = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  # Systemd for user services
  systemd.user = {
    enable = true;

    # systemctl --user status backup-XXX.timer
    # systemctl --user status backup-XXX.service
    # journalctl --user -u backup-XXX -f # follows
    # journalctl --user -xeu backup-XXX # pages down to end and adds more info
    services = {
      backup-borg = {
        Unit = {
          Description = "Backup computer files using borg.";
          Requires = "backup-borg.timer";
          OnFailure = "notify@%i.service";
        };
        Service = {
          Type = "simple";
          ExecStart = "/home/${vars.user}/bin/desktop/backup-borg";
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
          ExecStart = "/home/${vars.user}/bin/desktop/backup-secrets";
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
          ExecStart = "/home/${vars.user}/bin/desktop/backup-workstation";
        };
      };

      # @ means it's a template that accepts a single parameter. e.g. you could run `systemctl --user start notify@mysvc.service`
      "notify@" = {
        Unit = {
          Description = "Send Desktop Notification";
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${config.home.profileDirectory}/bin/notify-send --urgency=critical '%i' 'Error running %i service.'";
        };
      };
    };

    # OnStartupSec - Triggers the service to run this amount of time after login, since this is a user service.
    # OnUnitActiveSec - Triggers the service to run this amount of time after the last execution ("last activated").
    timers = {
      backup-borg = {
        Unit = {
          Description = "Timer for the backup-borg.service";
        };

        Timer = {
          Unit = "backup-borg.service";
          OnCalendar = "*-*-* 18:00:00"; # daily at 6:00 PM
        };

        Install = {
          WantedBy = [ "timers.target" ];
        };
      };

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

  xdg.desktopEntries = {
    filen = {
      name = "Filen";
      genericName = "File Syncer";
      exec = "filen-desktop";
      terminal = false;
      categories = [
        "Application"
        "Network"
      ];
    };
  };
}
