{
  ...
}:
{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c1f58b52-c92c-490e-8393-17fdcf5c41a3";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7026-7782";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/2714739c-89f0-4c66-a752-bb355e698140"; }
  ];
}
