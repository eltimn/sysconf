{
  lib,
  ...
}:
let
  rucaKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXS57Mn5Hsbkyv/byapcmgEVkRKqEnudWaCSDmpkRdb nelly@ruca";
  lappyKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILKlXvCa8D1VqasrHkgsnajPhaUA5N2pJ0b9OASPqYij nelly@lappy";
  illmaticKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPuurkk9SbjlyP27n5qSA17WCHkqL+3skETa/jIZsGH6 nelly@illmatic";
in
{
  options.sysconf.settings = {
    timezone = lib.mkOption {
      type = lib.types.str;
      default = "America/Chicago";
      description = "System timezone.";
    };

    hostRole = lib.mkOption {
      type = lib.types.str;
      default = "server"; # desktop|server
      description = "Host role - determines which programs/services are enabled.";
    };

    desktopEnvironment = lib.mkOption {
      type = lib.types.str;
      default = "none"; # cosmic|gnome|none
      description = "Desktop Environment used.";
    };

    homeDomain = lib.mkOption {
      type = lib.types.str;
      description = "The home domain.";
      default = "home.eltimn.com";
      internal = true;
    };

    borgRepo = lib.mkOption {
      type = lib.types.str;
      description = "The URL of the Borg backup repo.";
      default = "ssh://dl2juhyh@dl2juhyh.repo.borgbase.com/./repo";
      internal = true;
    };

    dnsServers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "The DNS servers to use for the home network.";
      default = [
        "10.42.40.27"
        "10.42.10.22"
      ];
      internal = true;
    };

    sshKeys = lib.mkOption {
      type = lib.types.attrs;
      description = "SSH keys";
      default = {
        deploy = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBx/kbRzJWh4XIXitaJ0j8kDukQ1zWTg17XzZzdy7dCu github-actions-deploy"
        ];

        nelly = {
          ruca = rucaKey;
          lappy = lappyKey;
          illmatic = illmaticKey;
          base = [
            rucaKey
            lappyKey
          ];
          all = [
            rucaKey
            lappyKey
            illmaticKey
          ];
        };
      };
      internal = true;
    };
  };
}
