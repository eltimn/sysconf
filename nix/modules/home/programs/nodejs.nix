# This setup allows installing npm packages globally to ~/.npm-packages
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.programs.nodejs;
  npmPkgsHome = "\${HOME}/.npm-packages";
in
{
  options.sysconf.programs.nodejs = {
    enable = lib.mkEnableOption "nodejs";
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.nodejs_24 ];

      file.".npmrc".text = ''
        prefix = ${npmPkgsHome}
      '';

      sessionPath = [ "${npmPkgsHome}/bin" ];
      sessionVariables = {
        NODE_PATH = "${npmPkgsHome}/lib/node_modules";
      };
    };
  };
}

# https://matthewrhone.dev/nixos-npm-globally
