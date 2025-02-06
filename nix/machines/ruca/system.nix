{
  lib,
  pkgs,
  vars,
  readSecretFile,
  ...
}:

{
  # linux kernel
  boot.kernelPackages = pkgs.linuxPackages_6_13;
  boot.supportedFilesystems.zfs = lib.mkForce false;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # security.sudo.execWheelOnly = true;

  # Enable the windowing system.
  # services.xserver is a misnomer, it was created before wayland existed.
  services.xserver = {
    enable = true;
    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    # Configure keymap
    xkb = {
      layout = "us";
      variant = "";
    };
    # libinput.enable = false; # Disable touchpad support (enabled default in most desktopManager).
    # videoDrivers = [ "nvidia" ]; # Load nvidia driver for Xorg and Wayland
    videoDrivers = [ "amdgpu" ]; # amd drivers
  };

  # boot.postBootCommands = ''
  #   mount -o remount,ro,bind,noatime,discard /nix/store
  # '';

  # nvidia stuff - video card needs legacy_470
  # Enable OpenGL
  # hardware.graphics = {
  #   enable = true;
  # };

  # hardware.nvidia = {

  #   # Modesetting is required.
  #   modesetting.enable = true;

  #   # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
  #   # Enable this if you have graphical corruption issues or application crashes after waking
  #   # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
  #   # of just the bare essentials.
  #   powerManagement.enable = false;

  #   # Fine-grained power management. Turns off GPU when not in use.
  #   # Experimental and only works on modern Nvidia GPUs (Turing or newer).
  #   powerManagement.finegrained = false;

  #   # Use the NVidia open source kernel module (not to be confused with the
  #   # independent third-party "nouveau" open source driver).
  #   # Support is limited to the Turing and later architectures. Full list of
  #   # supported GPUs is at:
  #   # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
  #   # Only available from driver 515.43.04+
  #   # Currently alpha-quality/buggy, so false is currently the recommended setting.
  #   open = false;

  #   # Enable the Nvidia settings menu,
  #   # accessible via `nvidia-settings`.
  #   nvidiaSettings = true;

  #   # Optionally, you may need to select the appropriate driver version for your specific GPU.
  #   package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  # };

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
  users.users."${vars.user}" = {
    isNormalUser = true;
    description = "Tim Nelson";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    initialHashedPassword = "$y$j9T$gBvMn/QrY5RosPhMxJ3.21$iwvCDJ3H41QrsRuBzBUQfYwKW1.WjRfnybFMiGJnIx8";
    openssh.authorizedKeys.keys = [
      # sshKeys.lappy
    ];
    shell = pkgs.zsh;
  };

  # https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
  # Exclude some packages from gnome
  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
      gnome-text-editor
    ])
    ++ (with pkgs; [
      cheese # webcam tool
      gnome-music
      #gnome-terminal
      epiphany # web browser
      geary # email reader
      evince # document viewer
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      gnome-calculator
      yelp # help viewer
      gnome-maps
      gnome-weather
      gnome-contacts
      simple-scan
    ]);

  # Cinnamon desktop
  # services.xserver = {
  #   enable = true;
  #   libinput.enable = true;
  #   displayManager.lightdm.enable = true;
  #   desktopManager = { cinnamon.enable = true; };
  #   displayManager.defaultSession = "cinnamon";
  #   xkb = {
  #     layout = "us";
  #     variant = "";
  #   };
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gum
    jq
    tree
    ventoy
    vim
    wget
  ];

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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "24.11"; # Don't touch

  # Enable Nix Flakes and nix command
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
