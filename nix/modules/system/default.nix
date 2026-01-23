# This is included on every host
{
  config,
  lib,
  pkgs,
  ...
}:
let
  settings = config.sysconf.settings;
in
{
  imports = [
    ./containers
    ./desktop
    ./services
    ./users
    ./settings.nix
    ./sops.nix
  ];

  config = lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
        age
        bat
        btop
        dnsutils
        dysk
        ghostty.terminfo
        git
        gptfdisk
        gum
        htop
        jq
        ncdu
        parted
        s3cmd
        sshfs
        stow
        tldr
        tree
        unzip
        usbutils
        vim
        wget
        whois
      ];

      # Users are immutable
      users.mutableUsers = false;

      programs.zsh.enable = true;

      # timezone
      time.timeZone = settings.timezone;

      # networking
      networking.firewall.enable = true;

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
    }

    (lib.mkIf (settings.desktopEnvironment == "gnome") {
      sysconf.desktop.gnome.enable = true;
    })
    (lib.mkIf (settings.desktopEnvironment == "cosmic") {
      sysconf.desktop.cosmic.enable = true;
    })
  ];
}
