# This user is used for doing deployments via Colmena
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.users.sysconf;
  sshKeys = config.sysconf.settings.sshKeys;
in
{
  options.sysconf.users.sysconf = {
    enable = lib.mkEnableOption "sysconf";
  };

  config = lib.mkIf cfg.enable {

    users = {
      users."sysconf" = {
        isSystemUser = true;
        group = "sysconf";
        home = "/var/lib/sysconf";
        createHome = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = sshKeys.nelly.base ++ sshKeys.deploy;
        shell = pkgs.bash;
      };

      groups."sysconf" = { };
    };

    # Passwordless sudo for sysconf user (required by Colmena)
    security.sudo.extraRules = [
      {
        users = [ "sysconf" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    # Allow sysconf user to receive unsigned store paths for remote deployment
    nix.settings.trusted-users = [
      "root"
      "sysconf"
    ];
  };
}
