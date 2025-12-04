{lib, ...}: {
  imports = [
    ./rclone
    ./rke2
    ./tailscale
    ./networking
    ./haproxy
    ./shell
    ./disko
    ./keepalived
  ];
  # --- Disks --- #
  disko-disks = {
    enable = lib.mkDefault true;
    local-storage.enable = lib.mkDefault true;
  };

  # --- Networking --- #
  tailscale-server.enable = lib.mkDefault true;
  net.enable = lib.mkDefault true;
  keepalived.enable = lib.mkDefault false;

  # --- Services --- #
  sftp.enable = lib.mkDefault false;
  haproxy.enable = lib.mkDefault false;

  #-- Shell --#
  starship.enable = lib.mkDefault true;
}
