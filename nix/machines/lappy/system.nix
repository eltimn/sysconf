{ config, ... }:
let
  settings = config.sysconf.settings;
in
{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  sops.secrets."users/nelly/password".neededForUsers = true;

  sysconf = {
    settings.hostRole = "desktop";
    settings.desktopEnvironment = "gnome";

    users.nelly = {
      enable = true;
      hashedPasswordFile = config.sops.secrets."users/nelly/password".path;
    };

    services.wireguard = {
      enable = true;
      address = [ "10.42.12.2/32" ];
      dns = [
        "10.42.10.22"
        "10.42.10.23"
      ];
      serverPublicKey = "TNLVb4Fx/S7XjORz/Uu+gGnWOt2/aui+//dTImziOW0=";
      endpoint = "pad.eltimn.com:51820";
      allowedIPs = [ "0.0.0.0/0" ];
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Needed for yubikey
  services.pcscd.enable = true;

  # networking
  networking = {
    hostName = "lappy";
    search = [ settings.homeDomain ];
    # system tray applet
    networkmanager.enable = true;
    # Optional: Disable IPv6 if not needed
    enableIPv6 = false;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
