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
        openssh.authorizedKeys.keys = config.sysconf.settings.sshKeys.nelly.base;
        shell = pkgs.zsh;
      };
    };
  };
}
