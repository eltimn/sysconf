{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-CT1000P3SSD8_24414B7BA68A";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              label = "boot";
              # size = "1024M";
              start = "1M";
              end = "1024M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };

            # btrfs
            # root = {
            #   size = "100%";
            #   label = "root";
            #   content = {
            #     type = "btrfs";
            #     extraArgs = [
            #       "-L"
            #       "nixos"
            #       "-f"
            #     ];
            #     subvolumes = {
            #       "/root" = {
            #         mountpoint = "/";
            #         mountOptions = [
            #           "subvol=root"
            #           "compress=zstd"
            #           "noatime"
            #         ];
            #       };
            #       "/home" = {
            #         mountpoint = "/home";
            #         mountOptions = [
            #           "subvol=home"
            #           "noatime"
            #         ];
            #       };
            #       "/data" = {
            #         mountpoint = "/data";
            #         mountOptions = [
            #           "subvol=data"
            #           "compress=zstd"
            #           "noatime"
            #         ];
            #       };
            #       "/nix" = {
            #         mountpoint = "/nix";
            #         mountOptions = [
            #           "subvol=nix"
            #           "compress=zstd"
            #           "noatime"
            #         ];
            #       };
            #       "/swap" = {
            #         mountpoint = "/swap";
            #         swap.swapfile.size = "32G";
            #       };
            #     };
            #   };
            # };
          };
        };
      };
    };
  };

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-label/data";
    fsType = "ext4";
  };
}
