{ pkgs, ... }:
{
  home.packages = [ pkgs.ollama ];

  # ----------- Ollama service -----------------
  services.ollama = {
    enable = true;
    port = 8080;
    host = "127.0.0.1"; # default

    # Optional extra flags – for example, enable verbose logging:
    # extraOptions = [ "--verbose" ];

    # Optional environment variables
    # environment = { OLLAMA_DEBUG = "1"; };

    # If you need to tweak systemd directly, use serviceConfig:
    # serviceConfig = {
    #   MemoryLimit = "2G";
    #   CPUQuota    = "80%";
    # };
  };
}
