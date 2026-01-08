{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  imports = [
    ../../modules/system
    # ../../modules/system/de/gnome.nix
    ../../modules/system/de/cosmic.nix
  ];

  sysconf.settings.gitEditor = "micro";

  # linux kernel
  # boot.kernelPackages = pkgs.linuxPackages_6_13; # need this to support the Realtek 2.5G NIC
  # boot.supportedFilesystems.zfs = lib.mkForce false; # this is because zfs kernel modules are usually behind and don't compile with the newer kernels.

  # GNOME specific configuration
  # sysconf.system.gnome = {
  #   videoDrivers = [ "amdgpu" ];
  # };

  sysconf.system.cosmic.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [
      pkgs.vulkan-loader
      pkgs.vulkan-tools
      pkgs.vulkan-headers
    ];
  };

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
    clinfo
    isd
    pciutils
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
      # "llama3.2:3b"
      # "devstral-small-2:24b"
      "qwen3-coder:30b"
      # "deepseek-r1:7b"
      "deepseek-r1:8b"
    ];

    acceleration = "vulkan";
    host = "127.0.0.1";
    port = 11434;
    openFirewall = false;
    environmentVariables = {
      OLLAMA_DEBUG = "2";
      OLLAMA_CONTEXT_LENGTH = "16384";
      GGML_VK_VISIBLE_DEVICES = "1"; # Use only R9700 (GPU1 in Vulkan), not iGPU (GPU0)
    };
  };

  # services.nextjs-ollama-llm-ui = {
  #   enable = true;
  #   port = 8080;
  #   ollamaUrl = "http://127.0.0.1:" + toString config.services.ollama.port;
  # };

  # Add Ollama to video and render groups for GPU access
  systemd.services.ollama.serviceConfig.SupplementaryGroups = [
    "video"
    "render"
  ];

  # Disabled in favor of llama-swap which manages llama.cpp for us
  # services.llama-cpp = {
  #   enable = true;
  #   package = pkgs-unstable.llama-cpp-vulkan;
  #   port = 8090;
  #   model = /home/nelly/.cache/llama.cpp/unsloth_Qwen3-Coder-30B-A3B-Instruct-GGUF_Qwen3-Coder-30B-A3B-Instruct-UD-Q4_K_XL.gguf;
  # };

  # Create models directory for llama-swap
  systemd.tmpfiles.rules = [
    "d /var/lib/llama-swap 0755 llama-swap llama-swap -"
    "d /var/lib/llama-swap/models 0755 llama-swap llama-swap -"
  ];

  services.llama-swap = {
    enable = true;
    port = 8091;

    settings = {
      models = {
        "qwen3-coder:30b" = {
          cmd = ''
            ${pkgs-unstable.llama-cpp-vulkan}/bin/llama-server \
              --model /var/lib/llama-swap/models/Qwen3-Coder-30B-A3B-Instruct-UD-Q4_K_XL.gguf \
              --port ''${PORT} \
              --ctx-size 12288 \
              --threads 8
          '';
        };

        # Add more models here as needed
        # "deepseek-r1:8b" = {
        #   cmd = ''
        #     ${pkgs-unstable.llama-cpp-vulkan}/bin/llama-server \
        #       --model /var/lib/llama-swap/models/deepseek-r1-8b.gguf \
        #       --port ''${PORT} \
        #       --ctx-size 8192
        #   '';
        # };
      };
    };
  };

  # sysconf services
  sysconf.services = {
    coredns.enable = true;
  };

  # state version
  system.stateVersion = "24.11"; # Don't touch
}
