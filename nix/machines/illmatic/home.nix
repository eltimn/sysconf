{
  config,
  pkgs,
  vars,
  ...
}:
{

  imports = [
    ../../home/common
    ../../home/programs/direnv.nix
    ../../home/programs/git
    ../../home/programs/tmux.nix
    ../../home/programs/zsh
  ];

  home = {
    username = "${vars.user}";
    homeDirectory = "/home/${vars.user}";
    stateVersion = "24.05";

    packages = with pkgs; [
      gnumake
      stow
    ];

    sessionPath = [
      "$HOME/bin/common"
      "$HOME/bin"
    ];
    sessionVariables = {
      EDITOR = "${vars.editor}";
      # not sure why these are not set already. systemctl doesn't work without them.
      XDG_RUNTIME_DIR = "/run/user/\$(id -u)";
      DBUS_SESSION_BUS_ADDRESS = "unix:path=$XDG_RUNTIME_DIR/bus";
    };
  };

  # Packages that are installed as programs also allow for configuration.
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };

  # Systemd for user services
  systemd.user = {
    enable = true;

    # systemctl --user status backup-XXX.timer
    # systemctl --user status backup-XXX.service
    # journalctl --user -u backup-XXX -f # follows
    # journalctl --user -xeu backup-XXX # pages down to end and adds more info
    services = {
      backup-nas = {
        Unit = {
          Description = "Backup computer files using borg.";
          Requires = "backup-nas.timer";
          OnFailure = "notify@%i.service";
        };
        Service = {
          Type = "simple";
          ExecStart = "/home/${vars.user}/bin/backup-nas";
        };
      };

      # @ means it's a template that accepts a single parameter. e.g. you could run `systemctl --user start notify@mysvc.service`
      "notify@" = {
        Unit = {
          Description = "Send Desktop Notification";
        };

        Service = {
          Type = "oneshot";
          ExecStart = "curl -H 'Title: %i' https://ntfy.home.eltimn.com/backups -d 'Error running %i service.'";
        };
      };
    };

    # OnStartupSec - Triggers the service to run this amount of time after login, since this is a user service.
    # OnUnitActiveSec - Triggers the service to run this amount of time after the last execution ("last activated").
    timers = {
      backup-nas = {
        Unit = {
          Description = "Timer for the backup-nas.service";
        };

        Timer = {
          Unit = "backup-nas.service";
          OnCalendar = "daily";
        };

        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
  };
}
