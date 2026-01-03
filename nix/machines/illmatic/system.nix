{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ../../system/containers
    ../../system/services
    ../../system/sysconf-user.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable ZFS support
  # https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/index.html
  # https://nixos.org/manual/nixos/stable/options.html#opt-networking.hostId
  boot.supportedFilesystems = [
    "zfs"
    "ext4"
  ];

  # Allow sysconf user to receive unsigned store paths for remote deployment
  nix.settings.trusted-users = [
    "root"
    "sysconf"
  ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "60a48c03"; # Unique among my machines. Generated with: `head -c 4 /dev/urandom | sha256sum | cut -c1-8`

  sops.secrets."users/${config.sysconf.settings.primaryUsername}/password".neededForUsers = true;

  # Define a user account.
  users = {
    mutableUsers = false;
    users = {
      "${config.sysconf.settings.primaryUsername}" = {
        isNormalUser = true;
        description = "Tim Nelson";
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        openssh.authorizedKeys.keys = config.sysconf.settings.primaryUserSshKeys;
        shell = pkgs.zsh;
        hashedPasswordFile =
          config.sops.secrets."users/${config.sysconf.settings.primaryUsername}/password".path;
      };
    };
  };

  # sops
  sops.age.sshKeyPaths = [
    "${config.users.users.${config.sysconf.settings.primaryUsername}.home}/.ssh/id_ed25519"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    age
    borgbackup
    gum
    jq
    parted
    stow
    tree
    vim
    wget
  ];

  programs.zsh.enable = true;

  # Enable services
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

    immich = {
      enable = true;
      port = 2283; # default is 2283
    };
  };

  # systemd.tmpfiles.rules = [ "d /srv/nocodb 2770 podman podman -" ];

  # Enable podman
  # virtualisation = {
  #   podman = {
  #     enable = true;

  #     # Create a `docker` alias for podman, to use it as a drop-in replacement
  #     # dockerCompat = true;

  #     # Required for containers under podman-compose to be able to talk to each other.
  #     # defaultNetwork.settings.dns_enabled = true;
  #   };
  # };

  # virtualisation.oci-containers = {
  #   backend = "podman";

  #   containers = {
  #     # nocodb = {
  #     #   image = "nocodb/nocodb:latest";
  #     #   autoStart = true;
  #     #   user = "podman:podman";
  #     #   volumes = [ "/srv/nocodb:/usr/app/data/" ];
  #     #   ports = [ "8080:8080" ];
  #     # };
  #     # channels-dvr = {
  #     #   image = "fancybits/channels-dvr:latest";
  #     #   autoStart = true;
  #     #   ports = [
  #     #     "8089:8089"
  #     #     "5353:5353"
  #     #   ];
  #     #   volumes = [
  #     #     "/mnt/dvr-config:/channels-dvr"
  #     #     "/mnt/dvr-recordings:/shares/DVR"
  #     #     "/mnt/tv:/mnt/tv"
  #     #     "/mnt/movies:/mnt/movies"
  #     #     "/mnt/videos:/mnt/videos"
  #     #   ];
  #     #   devices = [ "/dev/dri:/dev/dri" ];
  #     #   restartPolicy = "on-failure:10"; # unless-stopped
  #     #   labels = [
  #     #     "homepage.group=Media"
  #     #     "homepage.name=ChannelsDVR"
  #     #     "homepage.icon=channels.png"
  #     #     "homepage.href=https://dvr.home.eltimn.com/"
  #     #     "homepage.description=DVR Server"
  #     #     "homepage.widget.type=channelsdvrserver"
  #     #     "homepage.widget.url=http://channels-dvr:8089"
  #     #   ];
  #     # };
  #   };
  # };

  # sysconf containers & services
  sysconf = {
    containers = {
      channels-dvr.enable = true;
    };

    services = {
      caddy = {
        enable = true;
        domain = "home.eltimn.com";
      };
      coredns = {
        enable = true;
      };
      jellyfin = {
        enable = true;
        # port = 8096;
      };
      ntfy = {
        enable = true;
        port = 8082;
        baseUrl = "https://ntfy.home.eltimn.com";
      };
    };
  };

  ## system
  system.stateVersion = "25.11"; # Don't touch unless installing a new system
}
