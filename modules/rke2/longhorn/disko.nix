{
  lib,
  config,
  ...
}: {
  disko.devices.disk.longhorn-00 = lib.mkIf config.longhorn.disks.longhorn-00.enable {
    name = "longhorn";
    device = "/dev/nvme1n1";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        longhorn = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/mnt/longhorn-00";
          };
        };
      };
    };
  };
}
