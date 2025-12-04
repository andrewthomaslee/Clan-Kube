{
  config,
  pkgs,
  lib,
  ...
}: let
  iface = "${config.net.iface}.4000";
in {
  options.keepalived = {
    enable = lib.mkEnableOption "keepalived with floating IPs";
    VIPv4 = lib.mkOption {
      type = lib.types.str;
      description = "Floating IPv6 address";
      default = "10.0.42.1";
    };
    priority = lib.mkOption {
      type = lib.types.int;
      description = "Priority of the VIP";
    };
    unicastSrcIp = lib.mkOption {
      type = lib.types.str;
      description = "Unicast source IP";
      default = "${config.net.nodeIPv4}";
    };
    unicastPeers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Unicast peers";
    };
  };

  config = lib.mkIf config.keepalived.enable {
    services.keepalived = {
      enable = true;
      openFirewall = true;
      extraGlobalDefs = ''
        use_symlink_paths true
        max_auto_priority 1
      '';
      vrrpInstances.rke2_1 = {
        priority = config.keepalived.priority;
        unicastSrcIp = config.keepalived.unicastSrcIp;
        unicastPeers = config.keepalived.unicastPeers;
        interface = "${iface}";
        virtualRouterId = 1;
        virtualIps = [
          {
            addr = config.keepalived.VIPv4;
            dev = "${iface}";
          }
        ];
      };
    };
  };
}
