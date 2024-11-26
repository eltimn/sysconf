# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, username, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Enable Nix Flakes and nix command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "cbox";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

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

  # Define a user account.
  users = {
    groups = { podman = { }; };

    users = {
      nelly = {
        isNormalUser = true;
        description = "Tim Nelson";
        extraGroups = [ "wheel" "networkmanager" "docker" ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDklahMXXjjNfToRDOjLsIwUl3a3C3W7/X7wEMBca8lo nelly@pop-os"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILKlXvCa8D1VqasrHkgsnajPhaUA5N2pJ0b9OASPqYij tim@lappy"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXS57Mn5Hsbkyv/byapcmgEVkRKqEnudWaCSDmpkRdb nelly@ruca"
        ];
        shell = pkgs.zsh;
      };

      podman = {
        isSystemUser = true;
        group = "podman";
        description = "User to run podman containers";
      };
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ jq tree vim wget turso-cli ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.zsh.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    allowSFTP = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # services.vaultwarden = {
  #   enable = true;
  #   dbBackend = "sqlite";
  #   config = {
  #     DOMAIN = "https://bitwarden.home.eltimn.com";
  #     SIGNUPS_ALLOWED = false;

  #     # Vaultwarden currently recommends running behind a reverse proxy
  #     # (nginx or similar) for TLS termination, see
  #     # https://github.com/dani-garcia/vaultwarden/wiki/Hardening-Guide#reverse-proxying
  #     # > you should avoid enabling HTTPS via vaultwarden's built-in Rocket TLS support,
  #     # > especially if your instance is publicly accessible.
  #     #
  #     # A suitable NixOS nginx reverse proxy example config might be:
  #     #
  #     #     services.nginx.virtualHosts."bitwarden.home.eltimn.com" = {
  #     #       enableACME = true;
  #     #       forceSSL = true;
  #     #       locations."/" = {
  #     #         proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
  #     #       };
  #     #     };
  #     ROCKET_ADDRESS = "127.0.0.1";
  #     ROCKET_PORT = 8222;

  #     ROCKET_LOG = "critical";

  #     # This example assumes a mailserver running on localhost,
  #     # thus without transport encryption.
  #     # If you use an external mail server, follow:
  #     #   https://github.com/dani-garcia/vaultwarden/wiki/SMTP-configuration
  #     # SMTP_HOST = "127.0.0.1";
  #     # SMTP_PORT = 25;
  #     # SMTP_SSL = false;

  #     # SMTP_FROM = "admin@bitwarden.home.eltimn.com";
  #     # SMTP_FROM_NAME = "eltimn.com Bitwarden server";
  #   };
  # };

  # services.nginx.virtualHosts."bitwarden.home.eltimn.com" = {
  #   enableACME = true;
  #   forceSSL = true;
  #   locations."/" = {
  #     proxyPass = "http://127.0.0.1:${
  #         toString config.services.vaultwarden.config.ROCKET_PORT
  #       }";
  #   };
  # };

  # systemd.tmpfiles.rules = [ "d /srv/nocodb 2770 podman podman" ];

  # Enable podman
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  virtualisation.oci-containers = {
    backend = "podman";

    containers = {
      cloudflared = {
        image = "cloudflare/cloudflared:latest";
        autoStart = true;
        cmd = [
          "tunnel"
          "run"
          "--token"
          "eyJhIjoiYzhmMjJlNDBhMTFhODNmOWYxZWRlMzdlNzQ4MzZiNzUiLCJ0IjoiOGM5NmJmNjktMDFlNC00MDFlLWI5Y2ItZmQ4NDYxODIwMzJhIiwicyI6Ik5EZ3hPRGxtT0dVdFpqaGtPQzAwTTJGa0xXSm1PV010WldGall6TmtPRGs0WXpZMiJ9"
        ];
      };

      # nocodb = {
      #   image = "nocodb/nocodb:latest";
      #   autoStart = true;
      #   user = "podman:podman";
      #   volumes = [ "/srv/nocodb:/usr/app/data/" ];
      #   ports = [ "8080:8080" ];
      # };
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}

