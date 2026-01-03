{ config, ... }:
{

  sops.secrets."users/sysconf/password".neededForUsers = true;

  users = {
    users = {
      sysconf = {
        isSystemUser = true;
        group = "sysconf";
        home = "/var/lib/sysconf";
        createHome = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = config.sysconf.settings.primaryUserSshKeys;
        shell = "/run/current-system/sw/bin/bash";
        hashedPasswordFile = config.sops.secrets."users/sysconf/password".path;
      };
    };

    groups.sysconf = { };
  };
}
