{lib, ...}: {
  imports = [
    ./rclone
    ./k3s
    ./tailscale
    ./keepalived
    ./nat64
    ./longhorn
  ];
  k3s = {
    enable = lib.mkDefault false;
    manager = lib.mkDefault false;
  };
  keepalived-web.enable = lib.mkDefault false;
  longhorn.enable = lib.mkDefault false;
  nat64.enable = lib.mkDefault true;
  sftp.enable = lib.mkDefault false;
  tailscale-server.enable = lib.mkDefault true;
}
