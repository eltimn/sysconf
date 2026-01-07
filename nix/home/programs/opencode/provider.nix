# Providers configuration for opencode

{
  lib,
  config,
  osConfig,
  ...
}:

let
  cfg = config.sysconf.programs.opencode;
in
{
  programs.opencode.settings.provider = lib.mkIf cfg.enable {
    ollama = {
      npm = "@ai-sdk/openai-compatible";
      name = "Ollama (local)";
      options = {
        baseURL =
          "http://" + osConfig.services.ollama.host + ":" + toString osConfig.services.ollama.port + "/v1/";
      };
      models = {
        gptoss = {
          name = "GPT-OSS 20B";
          id = "gpt-oss:20b";
        };
        # Only works with a tiny context length
        # devstral = {
        #   name = "Devstral Small 2";
        #   id = "devstral-small-2:24b";
        # };
        qwen3coder = {
          name = "Qwen3 Coder 30B";
          id = "qwen3-coder:30b";
        };
      };
    };

    ollama-cloud = {
      npm = "@ai-sdk/openai-compatible";
      name = "Ollama (cloud)";
      options = {
        baseURL = "https://ollama.com/v1/";
        apiKey = "{env:OPENCODE_OLLAMA_CLOUD_APIKEY}";
      };
      models = {
        devstral = {
          name = "Devstral 2";
          id = "devstral-2:123b-cloud";
        };
        qwen3coder = {
          name = "Qwen3 Coder 480B";
          id = "qwen3-coder:480b-cloud";
        };
        glm4-7 = {
          name = "GLM 4.7";
          id = "glm-4.7:cloud";
        };
      };
    };

    # llama-swap = {
    #   npm = "@ai-sdk/openai-compatible";
    #   name = "llama-swap";
    #   options = {
    #     baseURL = "http://localhost:" + toString osConfig.services.llama-swap.port + "/v1/";
    #   };
    #   models = {
    #     qwen3coder = {
    #       name = "Qwen3 Coder 30B";
    #       id = "qwen3-coder:30b";
    #     };
    #   };
    # };

    # lmstudio = {
    #   npm = "@ai-sdk/openai-compatible";
    #   name = "LM Studio";
    #   options = {
    #     baseURL = "http://localhost:1234/v1/";
    #   };
    #   # models = {
    #   #   gptoss = {
    #   #     name = "GPT OSS 20B";
    #   #     id = "gpt-oss-20b";
    #   #   };
    #   # };
    # };
  };
}
