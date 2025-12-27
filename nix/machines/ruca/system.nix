{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  imports = [
    ../../system/services
  ];

  sysconf.settings.gitEditor = "gnome-text-editor -ns";

  # linux kernel
  # boot.kernelPackages = pkgs.linuxPackages_6_13; # need this to support the Realtek 2.5G NIC
  # boot.supportedFilesystems.zfs = lib.mkForce false; # this is because zfs kernel modules are usually behind and don't compile with the newer kernels.

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [
      pkgs.rocmPackages.clr.icd
      pkgs.vulkan-loader
      pkgs.vulkan-tools
      pkgs.vulkan-headers
    ];
  };

  # security.sudo.execWheelOnly = true;

  # Enable the windowing system.
  # services.xserver is a misnomer, it was created before wayland existed.
  services.xserver = {
    enable = true;
    # Enable the GNOME Desktop Environment.
    # Configure keymap
    xkb = {
      layout = "us";
      variant = "";
    };
    # libinput.enable = false; # Disable touchpad support (enabled default in most desktopManager).
    # videoDrivers = [ "nvidia" ]; # Load nvidia driver for Xorg and Wayland
    videoDrivers = [ "amdgpu" ]; # amd drivers
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

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

  # Define a user account.
  users.users."${config.sysconf.settings.primaryUsername}" = {
    isNormalUser = true;
    description = "Tim Nelson";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = config.sysconf.settings.primaryUserSshKeys;
    shell = pkgs.zsh;
  };

  sops.age.sshKeyPaths = [
    "${config.users.users.${config.sysconf.settings.primaryUsername}.home}/.ssh/id_ed25519"
  ];

  # https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
  # Exclude some packages from gnome
  environment.gnome.excludePackages = (
    with pkgs;
    [
      gnome-photos
      gnome-tour
      cheese # webcam tool
      gnome-music
      epiphany # web browser
      geary # email reader
      evince # document viewer
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      yelp # help viewer
      gnome-maps
      gnome-weather
      gnome-contacts
      simple-scan
    ]
  );

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
  services.printing = {
    enable = true;
    # Add Brother printer drivers
    drivers = [
      pkgs.brlaser
    ];
    # logLevel = "debug";
  };

  # Allow network discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
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
    age
    clinfo
    gum
    isd
    jq
    parted
    pciutils
    rocmPackages.clr.icd
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
    tree
    # ventoy
    vim
    wget
    whois
  ];

  programs.zsh.enable = true;
  programs.gnupg.agent.enable = true;

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

  # Needed for yubikey
  services.pcscd.enable = true;

  # Ollama service
  services.ollama = {
    enable = true;
    package = pkgs-unstable.ollama-vulkan;

    loadModels = [
      "gpt-oss:20b"
      "llama3.2:3b"
      "devstral-small-2:24b"
      "qwen3-coder:30b"
      # "deepseek-r1:7b"
      # "deepseek-r1:8b"
    ];

    acceleration = "vulkan";
    host = "127.0.0.1";
    port = 11434;
    openFirewall = false;
    environmentVariables = {
      OLLAMA_DEBUG = "2";
      OLLAMA_CONTEXT_LENGTH = "8192";
      GGML_VK_VISIBLE_DEVICES = "1"; # Use only R9700 (GPU1 in Vulkan), not iGPU (GPU0)
    };
  };

  services.nextjs-ollama-llm-ui = {
    enable = true;
    port = 8080;
    ollamaUrl = "http://127.0.0.1:" + toString config.services.ollama.port;
  };

  # Add Ollama to video and render groups for GPU access
  systemd.services.ollama.serviceConfig.SupplementaryGroups = [
    "video"
    "render"
  ];

  # sysconf services
  sysconf.services.coredns = {
    enable = true;
  };

  # state version
  system.stateVersion = "24.11"; # Don't touch
}
