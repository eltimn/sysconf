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
    ../../home/desktop
    ../../home/programs/git
    ../../home/programs/vscode
    ../../home/programs/zsh
    ../../home/programs/direnv.nix
    ../../home/programs/firefox.nix
    ../../home/programs/tmux.nix
    ../../home/services/ollama.nix
  ];

  # fonts.fontconfig.enable = true;
  # xdg.mime.enable = false; # fixes a bug where nautilus crashes

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
        gemini-cli
        goose-cli
        nodejs # npx is needed for MCP servers
        yubioath-flutter
        vhs
        vulkan-tools
      ]
      ++ [
        pkgs-unstable.lmstudio
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
      EDITOR = "codium --new-window --wait";
      OLLAMA_HOST = ollamaUrl;
      # Global defaults for goose
      GOOSE_PROVIDER = "ollama";
      GOOSE_MODEL = "qwen3-next:80b-cloud";
      GOOSE_MODE = "smart_approve";
      LESSOPEN = "|bat --paging=never --color=always %s"; # use bat for syntax highlighting with less
    };

    # some files
    file.".config/borg/backup_dirs".text =
      "export BACKUP_DIRS='Audio Documents Notes Pictures code secret-cipher sysconf'";
    # autostart files (run on login)
    file.".config/autostart/filen.desktop".source = ./files/filen.desktop;
    file.".config/autostart/mount-secret.desktop".source = ./files/mount-secret.desktop;
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

    # ghostty doesn't work with current ruca hardware
    # (ghostty:80405): Gtk-WARNING **: 20:23:38.051: No IM module matching GTK_IM_MODULE=ibus found
    # error(gtk_surface): surface failed to realize: Failed to create EGL display
    # warning(gtk_surface): this error is usually due to a driver or gtk bug
    # warning(gtk_surface): this is a common cause of this issue: https://gitlab.gnome.org/GNOME/gtk/-/issues/4950
    ghostty = {
      enable = true;
      enableZshIntegration = true;
    };

    opencode = {
      enable = true;
      package = pkgs-unstable.opencode;

      settings = {
        provider = {
          ollama = {
            npm = "@ai-sdk/openai-compatible";
            name = "Ollama (local)";
            options = {
              baseURL = "http://" + osConfig.services.ollama.host + ":" + toString osConfig.services.ollama.port;
            };
            models = {
              llama = {
                name = "Llama 3.2";
                id = "a80c4f17acd5";
              };
            };
          };
        };
      };
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
