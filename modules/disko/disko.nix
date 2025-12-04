{
  lib,
  config,
  pkgs,
  ...
}: {
  options.disko-disks = {
    enable = lib.mkEnableOption "enable disko-disks";
    local-storage.enable = lib.mkEnableOption "enable local-storage";
  };

  config = lib.mkIf config.disko-disks.enable {
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.efiInstallAsRemovable = true;
    boot.loader.grub.enable = true;
    disko.devices = {
      disk = {
        main = {
          name = "main";
          device = lib.mkDefault "/dev/nvme0n1";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              "boot" = {
                size = lib.mkDefault "5G";
                type = "EF02";
                priority = 1;
              };
              ESP = {
                type = "EF00";
                size = lib.mkDefault "5G";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["umask=0077"];
                };
              };
              root = {
                size = lib.mkDefault "300G";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
              local-storage = lib.mkIf config.disko-disks.local-storage.enable {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/mnt/local-storage";
                };
              };
            };
          };
        };
      };
    };
  };
}
