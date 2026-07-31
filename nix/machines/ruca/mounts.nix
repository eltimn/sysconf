{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # cifs-utils
    davfs2
  ];

  sops.secrets = {
    "webdav/fastmail" = {
      mode = "0600";
      path = "/etc/davfs2/secrets";
    };
  };

  services.davfs2.enable = true;

  systemd.mounts = [
    # {
    #   description = "Samba mount for homeserver media";
    #   after = [ "network-online.target" ];
    #   wants = [ "network-online.target" ];
    #   what = "//192.168.200.101/media";
    #   where = "/mnt/homeserver-media";
    #   options = "credentials=${config.sops.secrets.smbcreds.path},iocharset=utf8,rw,x-systemd.automount,uid=1000,gid=100,vers=3";
    #   type = "cifs";
    # }
    {
      description = "Fastmail webdav mount";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      what = "https://webdav.fastmail.com/";
      where = "/mnt/fastmail";
      options = "x-systemd.automount,uid=1000,gid=100";
      type = "davfs";
    }
  ];
  systemd.automounts = [
    # {
    #   description = "Samba automount for homeserver media";
    #   where = "/mnt/homeserver-media";
    #   wantedBy = [ "multi-user.target" ];
    #   automountConfig = {
    #     TimeoutIdleSec = "2m";
    #   };
    # }
    {
      description = "Fastmail webdav automount";
      where = "/mnt/fastmail";
      wantedBy = [ "multi-user.target" ];
      automountConfig = {
        TimeoutIdleSec = "2m";
      };
    }
  ];
}
