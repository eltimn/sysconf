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

  sysconf = {
    settings.hostRole = "desktop";
    settings.desktopEnvironment = "cosmic";

    users.nelly = {
      enable = true;
      hashedPasswordFile = config.sops.secrets."users/nelly/password".path;
      envEditor = "zeditor --wait";
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

  # Bluetooth (for wireless keyboards, mice, etc.)
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

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

    # Bluetooth CLI tools (e.g. bluetoothctl)
    bluez
    blueman
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

  # Persistent network interface naming
  systemd.network.links."10-lan" = {
    matchConfig.MACAddress = "10:ff:e0:83:15:15";
    linkConfig.Name = "eth0";
  };

  # networking
  networking = {
    hostName = "ruca";
    useDHCP = false; # NetworkManager handles this, but just to make sure.
    search = [ settings.homeDomain ];
    networkmanager.enable = true;
    enableIPv6 = false;

    # Static IP configuration for NetworkManager
    networkmanager.ensureProfiles.profiles = {
      eth0 = {
        connection = {
          id = "eth0";
          type = "ethernet";
          interface-name = "eth0";
        };
        ipv4 = {
          method = "manual";
          address1 = "10.42.40.27/24,10.42.40.1";
          dns = builtins.concatStringsSep ";" config.sysconf.settings.dnsServers;
        };
        ipv6.method = "disabled";
      };
    };
  };

  # state version
  system.stateVersion = "24.11"; # Don't touch
}
