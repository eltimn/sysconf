{
  config,
  pkgs,
  ...
}:
let
  settings = config.sysconf.settings;
in
{
  # linux kernel
  # boot.kernelPackages = pkgs.linuxPackages_6_13; # need this to support the Realtek 2.5G NIC
  # boot.supportedFilesystems.zfs = lib.mkForce false; # this is because zfs kernel modules are usually behind and don't compile with the newer kernels.

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  sops.secrets."users/nelly/password".neededForUsers = true;
  # sops.age.sshKeyPaths = [
  #   "${config.users.users.nelly.home}/.ssh/id_ed25519"
  # ];

  sysconf = {
    settings.hostRole = "desktop";
    settings.desktopEnvironment = "cosmic";

    users.nelly = {
      enable = true;
      hashedPasswordFile = config.sops.secrets."users/nelly/password".path;
    };

    # GNOME specific configuration
    # system.desktop.gnome = {
    #   videoDrivers = [ "amdgpu" ];
    # };
  };

  # graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    # Add Brother printer drivers
    drivers = [
      pkgs.brlaser
    ];
    # logLevel = "debug";
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    clinfo
    isd
    pciutils
  ];

  # Enable nix-ld for running dynamically linked executables
  # This allows running binaries from npm packages (like @github/copilot) that expect standard Linux library locations
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Additional libraries can be added here if needed
      stdenv.cc.cc.lib
    ];
  };

  programs.gnupg.agent.enable = true;

  # Needed for yubikey
  services.pcscd.enable = true;

  # sysconf services
  sysconf.services = {
    blocky.enable = true;
  };

  # networking
  networking = {
    hostName = "ruca";
    useDHCP = false;
    search = [ settings.homeDomain ];

    # system tray applet
    # networkmanager.enable = true;

    # Configure static IP on eth0
    interfaces."enp10s0" = {
      ipv4.addresses = [
        {
          address = "10.42.40.27";
          prefixLength = 24; # /24 subnet
        }
      ];
    };

    # Default gateway
    defaultGateway = {
      address = "10.42.40.1";
      interface = "enp10s0";
    };

    # DNS servers
    nameservers = config.sysconf.settings.dnsServers;

    # Optional: Disable IPv6 if not needed
    enableIPv6 = false;
  };

  # state version
  system.stateVersion = "24.11"; # Don't touch
}
