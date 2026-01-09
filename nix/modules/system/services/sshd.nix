{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.services.sshd;
in
{
  options.sysconf.services.sshd = {
    # enable this by default for servers
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "Whether to enable the SSH daemon.";
      default = config.sysconf.settings.hostRole == "server";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable the OpenSSH daemon
    services.openssh = {
      enable = true;
      # allowSFTP = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };
}
