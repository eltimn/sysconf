{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.users.nelly;
in
{
  options.sysconf.users.nelly = {
    enable = lib.mkEnableOption "nelly";
    hashedPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "The location of the hashed password file.";
      default = null;
    };

    sshKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "This user's SSH keys";
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILKlXvCa8D1VqasrHkgsnajPhaUA5N2pJ0b9OASPqYij nelly@lappy"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXS57Mn5Hsbkyv/byapcmgEVkRKqEnudWaCSDmpkRdb nelly@ruca"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPuurkk9SbjlyP27n5qSA17WCHkqL+3skETa/jIZsGH6 nelly@illmatic"
      ];
    };

    envEditor = lib.mkOption {
      type = lib.types.str;
      default = "nvim"; # "codium --new-window --wait"
      description = "The value to set the env var EDITOR";
    };

    gitEditor = lib.mkOption {
      type = lib.types.str;
      default = cfg.envEditor;
      description = "The git editor command.";
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users.nelly = {
        isNormalUser = true;
        description = "Tim Nelson";
        extraGroups = [
          "wheel"
          "networkmanager"
          "keys"
          "forgejo"
        ];
        hashedPasswordFile = cfg.hashedPasswordFile;
        openssh.authorizedKeys.keys = cfg.sshKeys;
        shell = pkgs.zsh;
      };
    };
  };
}
