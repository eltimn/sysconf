{ ... }:
{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  sysconf = {
    users = {
      nelly = {
        enable = true;
        hashedPasswordFile = "/run/keys/nelly-password";
      };
      sysconf.enable = true;
    };
  };

  # Define a user account.
  users = {
    groups = {
      podman = { };
      # ntfy = { };
    };

    users = {
      podman = {
        isSystemUser = true;
        group = "podman";
        description = "User to run podman containers";
      };

      # ntfy = {
      #   isSystemUser = true;
      #   group = "ntfy";
      #   description = "User to run ntfy.sh";
      # };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  #programs.gnupg.agent = {
  #  enable = true;
  #  enableSSHSupport = true;
  #};

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

    # sudo systemctl status podman-cloudflared.service
    # journalctl -xeu podman-cloudflared.service
    # Cloudflare - Zero Trust -> Networks -> Tunnels
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
  networking.firewall = {
    allowedTCPPorts = [ 8080 ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
