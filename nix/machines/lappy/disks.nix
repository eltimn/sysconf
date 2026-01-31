_: {
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b570639f-e42c-4f92-8704-329a56dbbdf9";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-acc832b7-54b4-488c-9784-b22d5db88e08".device =
    "/dev/disk/by-uuid/acc832b7-54b4-488c-9784-b22d5db88e08";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9398-B8EE";
    fsType = "vfat";
  };

  swapDevices = [ ];
}
