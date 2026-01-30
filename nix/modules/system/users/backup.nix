{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.users.backup;
in
{
  options.sysconf.users.backup = {
    enable = lib.mkEnableOption "backup";
  };

  config = lib.mkIf cfg.enable {
    users.groups."backup" = {
      members = [ "nelly" ];
    };
  };
}
