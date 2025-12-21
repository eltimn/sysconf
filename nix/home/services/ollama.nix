{ pkgs, ... }:
{
  home.packages = [ pkgs.ollama ];

  # ----------- Ollama service -----------------
  services.ollama = {
    enable = true;
    port = 8888;
    listenAddress = "127.0.0.1";

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
