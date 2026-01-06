{
  config,
  pkgs,
  pkgs-unstable,
  osConfig,
  ...
}:
let
  ollamaUrl =
    "http://" + osConfig.services.ollama.host + ":" + toString osConfig.services.ollama.port;
in
{

  imports = [
    ../../home/common
    ../../home/containers
    ../../home/desktop
    ../../home/cosmic
    ../../home/programs
    ../../home/programs/git
    ../../home/programs/goose
    ../../home/programs/vscode
    ../../home/programs/zsh
    ../../home/programs/direnv.nix
    ../../home/programs/firefox.nix
    ../../home/programs/tmux.nix
  ];

  sops.secrets."cloudflare_api_token" = { };
  sops.secrets."do_access_token" = { };
  sops.secrets."do_images_key" = { };
  sops.secrets."do_spaces_key" = { };

  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "${osConfig.sysconf.settings.primaryUsername}";
    homeDirectory = "/home/${osConfig.sysconf.settings.primaryUsername}";
    stateVersion = "24.11";

    # Packages that should be installed to the user profile.
    packages =
      with pkgs;
      [
        claude-code
        crush
        gemini-cli
        nodejs # npx is needed for MCP servers
        vulkan-tools
      ]
      ++ [
        # pkgs-unstable.lmstudio
        pkgs-unstable.radeontop
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
      # EDITOR = "codium --new-window --wait";
      EDITOR = "micro";
      LESSOPEN = "|bat --paging=never --color=always %s"; # use bat for syntax highlighting with less
      COSMIC_DATA_CONTROL_ENABLED = 1;
      OLLAMA_HOST = ollamaUrl;
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
    cosmic.primaryMonitor = "HDMI-A-1";

    programs.chromium.enable = true;
    programs.ghostty.enable = true;
    programs.goose.enable = true;
    programs.micro.enable = true;
    programs.opencode.enable = true;
    programs.rofi.enable = true;
    programs.zed-editor.enable = true;

    containers.mongodb-rz.enable = true;
    containers.postgresql-rz.enable = true;
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

      # @ means it's a template that accepts a single parameter. e.g. you could run `systemctl --user start notify@mysvc.service`
      "notify@" = {
        Unit = {
          Description = "Send Notification";
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
