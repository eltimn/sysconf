{ config, pkgs, ... }:
{
  users = {
    users = {
      sysconf = {
        isSystemUser = true;
        group = "sysconf";
        home = "/var/lib/sysconf";
        createHome = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys =
          config.sysconf.settings.primaryUserSshKeys ++ config.sysconf.settings.deployKeys;
        shell = pkgs.bash;
      };
    };

    groups.sysconf = { };
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
}
