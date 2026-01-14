# Ollama, llama.cpp, llama-swap, plus system config settings for use with Vulkan
{
  pkgs,
  pkgs-unstable,
  ...
}:
# let
#   ollamaUrl =
#     "http://" + osConfig.services.ollama.host + ":" + toString osConfig.services.ollama.port;
# in
{
  # OPENCODE_OLLAMA_BASEURL = "http://${osConfig.services.ollama.host}:${toString osConfig.services.ollama.port}/v1/";

  ## VSCod(e|ium)
  # "github.copilot.chat.byok.ollamaEndpoint": "http://127.0.0.1:11434",

  # home.sessionVariables = {
  #   OLLAMA_HOST = ollamaUrl;
  # };

  # pkgs-unstable.lmstudio
  # pkgs-unstable.radeontop

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [
      pkgs.vulkan-loader
      pkgs.vulkan-tools
      pkgs.vulkan-headers
    ];
  };

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
}
