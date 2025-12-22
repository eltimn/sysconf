{ config, lib, pkgs, ... }:
let
  cfg = config.sysconf.services.mcp-nixos;
in
{
  options.sysconf.services.mcp-nixos = {
    enable = lib.mkEnableOption "mcp-nixos";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.mcp-nixos = {
      description = "NixOS MCP Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      
      serviceConfig = {
        ExecStart = "${pkgs.mcp-nixos}/bin/mcp-nixos";
        Restart = "always";
        User = "nobody";
        Group = "nogroup";
      };
      
      environment = {
        ELASTICSEARCH_URL = "https://search.nixos.org/backend";
      };
    };
  };
}
