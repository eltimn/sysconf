{
  config,
  pkgs,
  vars,
  ...
}:
let
  nocodb-dir = "/var/lib/nocodb";
in
{
  system.stateVersion = "24.11"; # Don't touch

  # Optimization settings and garbage collection automation
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      sandbox = false; # needed to build custom caddy
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking
  networking.networkmanager.enable = true;
  networking.hostName = "${vars.host}";

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
    groups = {
      podman = { };
      # ntfy = { };
    };

    users = {
      "${vars.user}" = {
        isNormalUser = true;
        description = "Tim Nelson";
        extraGroups = [
          "wheel"
          "networkmanager"
          "podman"
        ];
        openssh.authorizedKeys.keys = [
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

      # ntfy = {
      #   isSystemUser = true;
      #   group = "ntfy";
      #   description = "User to run ntfy.sh";
      # };
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    jq
    tree
    neovim
    wget
  ];

  programs.zsh.enable = true;

  # Enable the OpenSSH daemon.
  services = {
    openssh = {
      enable = true;
      allowSFTP = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    # ntfy-sh = {
    #   enable = true;
    #   user = "ntfy";
    #   group = "ntfy";
    #   settings = {
    #     listen-http = ":8080";
    #     base-url = "https://ntfy.home.eltimn.com";
    #     behind-proxy = true;
    #     #auth-file = "/var/lib/ntfy/user.db";
    #     #auth-default-access = "deny-all";
    #   };
    # };

    # caddy = {
    #   enable = true;
    #   package = (
    #     pkgs.callPackage ./caddy.nix {
    #       plugins = [
    #         # dns.providers.cloudflare
    #         "github.com/caddy-dns/cloudflare"
    #       ];
    #       vendorSha256 = "0000000000000000000000000000000000000000000000000000";
    #     }
    #   );
    # };
  };

  systemd.services.create-container-dirs = with config.virtualisation.oci-containers; {
    serviceConfig.Type = "oneshot";
    wantedBy = [
      "${backend}-nocodb.service"
    ];
    script = ''
      [ -d ${nocodb-dir} ] || (mkdir -p ${nocodb-dir} && chown podman:podman ${nocodb-dir})
    '';
  };

  # How to create a network before hand:
  # https://madison-technologies.com/take-your-nixos-container-config-and-shove-it/

  # Deploying containers on nixos:
  # https://bkiran.com/blog/deploying-containers-nixos

  # Enable podman
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true; # dockge needs this

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers = {
      backend = "podman";

      # sudo systemctl status podman-cloudflared.service
      # journalctl -xeu podman-cloudflared.service
      # Cloudflare - Zero Trust -> Networks -> Tunnels
      containers = {
        # cloudflared = {
        #   image = "cloudflare/cloudflared:latest";
        #   autoStart = true;
        #   cmd = [
        #     "tunnel"
        #     "run"
        #     "--token"
        #     "eyJhIjoiYzhmMjJlNDBhMTFhODNmOWYxZWRlMzdlNzQ4MzZiNzUiLCJ0IjoiOGM5NmJmNjktMDFlNC00MDFlLWI5Y2ItZmQ4NDYxODIwMzJhIiwicyI6Ik5EZ3hPRGxtT0dVdFpqaGtPQzAwTTJGa0xXSm1PV010WldGall6TmtPRGs0WXpZMiJ9"
        #   ];
        # };

        nocodb = {
          image = "nocodb/nocodb:latest";
          autoStart = true;
          user = "995:993"; # kept getting: unable to find user podman: no matching entries in passwd file
          volumes = [ "${nocodb-dir}:/usr/app/data/" ];
          ports = [ "8080:8080" ];
          extraOptions = [
            "--pull=always"
          ];
        };

        # dockge = {
        #   image = "louislam/dockge:latest";
        #   autoStart = true;
        #   user = "podman:podman";
        #   volumes = [
        #     "/var/run/docker.sock:/var/run/docker.sock"
        #     "/var/lib/dockge/data:/app/data"
        #     "/opt/stacks:/opt/stacks"
        #   ];
        #   ports = [ "5001:5001" ];
        #   environment = {
        #     DOCKGE_STACKS_DIR = "/opt/stacks";
        #   };
        # };
      };
    };
  };

  # The firewall is enabled when not set.
  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      5001
      8080
    ];
  };
}

/*
        # If you want to use private registries, you need to share the auth file with Dockge:
        # - /root/.docker/:/root/.docker
*/
