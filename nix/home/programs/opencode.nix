{
  config,
  lib,
  pkgs-unstable,
  osConfig,
  ...
}:
let
  cfg = config.sysconf.programs.opencode;
in
{
  options.sysconf.programs.opencode = {
    enable = lib.mkEnableOption "opencode";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."ollama_api_key" = { };

    home.sessionVariables = {
      OPENCODE_DISABLE_AUTOUPDATE = "1";
      OPENCODE_EXPERIMENTAL_LSP_TOOL = "1";
      OPENCODE_OLLAMA_CLOUD_APIKEY = "$(cat ${config.sops.secrets."ollama_api_key".path})";
    };

    programs.opencode = {
      enable = true;
      package = pkgs-unstable.opencode;

      rules = ''
        # Global Project Rules

        ## External File Loading

        CRITICAL: When you encounter a file reference (e.g., @rules/general.md), use your Read tool to load it on a need-to-know basis, unless explicitly told to load immediately. They're relevant to the SPECIFIC task at hand.

        Instructions:

        - Do NOT preemptively load all references - use lazy loading based on actual need
        - When loaded, treat content as mandatory instructions that override defaults
        - Follow references recursively when needed

        # ## Development Guidelines

        # For TypeScript code style and best practices: @docs/typescript-guidelines.md
        # For React component architecture and hooks patterns: @docs/react-patterns.md
        # For REST API design and error handling: @docs/api-standards.md
        # For testing strategies and coverage requirements: @test/testing-guidelines.md

        # ## General Guidelines

        # Read the following file immediately as it's relevant to all workflows: @rules/general-guidelines.md.

        ## Running the Build Agent

        When executing the build agent, adhere to these additional rules:
        - Prioritize code correctness and security over speed.
        - Ensure all dependencies are explicitly declared.
        - Validate all external inputs rigorously.
        - Always confirm with the user that they intended to use the build agent before proceeding.
        - If the user asks you to make a plan, be sure to use the plan agent, not the build agent.
      '';

      settings = {
        tools = {
          lsp = true;
          nixos = false; # don't enable by default
        };

        mcp = {
          nixos = {
            type = "local";
            command = [
              "nix"
              "run"
              "github:utensils/mcp-nixos"
              "--"
            ];
            enabled = true;
          };
        };

        permission = {
          bash = {
            "git push" = "ask";
            "task switch" = "ask";
            "nixos-rebuild switch" = "ask";
            "sudo" = "deny";
          };
        };
        agent = {
          build = {
            permission = {
              bash = {
                "git push" = "allow";
              };
            };
          };
          plan = {
            tools = {
              nixos = true;
            };
          };
        };

        provider = {
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
        };
      };

      agents = {
        code-reviewer = ''
          # Code Reviewer Agent

          You are a senior software engineer specializing in code reviews.
          Focus on code quality, security, and maintainability.

          ## Guidelines
          - Review for potential bugs and edge cases
          - Check for security vulnerabilities
          - Ensure code follows best practices
          - Suggest improvements for readability and performance
        '';
        # documentation = ./agents/documentation.md;
      };
    };
  };
}
