{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

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
    extraPackages = [
      pkgs.vulkan-loader
      pkgs.vulkan-tools
      pkgs.vulkan-headers
    ];
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

  programs.gnupg.agent.enable = true;

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
    blocky.enable = true;
    coredns.enable = true;
  };

  # state version
  system.stateVersion = "24.11"; # Don't touch
}
