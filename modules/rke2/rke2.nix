{
  config,
  lib,
  pkgs,
  ...
}: {
  options.rke2 = {
    enable = lib.mkEnableOption "rke2";
    manager = lib.mkEnableOption "Control plane node";
    ipv4-cluster-cidr = lib.mkOption {
      type = lib.types.str;
      default = "10.42.0.0/16";
    };
    ipv4-service-cidr = lib.mkOption {
      type = lib.types.str;
      default = "10.43.0.0/16";
    };
    ipv6-cluster-cidr = lib.mkOption {
      type = lib.types.str;
      default = "fd08:2024:abba:0100::/56";
    };
    ipv6-service-cidr = lib.mkOption {
      type = lib.types.str;
      default = "fd08:2024:abba:0101::/112";
    };
  };

  config = lib.mkIf config.rke2.enable {
    clan.core.vars.generators.rke2 = {
      share = true;
      prompts = {
        "token" = {
          persist = true;
          type = "line";
          description = ''
            rke2 Token
          '';
          display.group = "rke2";
        };
      };
      files = {
        "token" = {};
      };
    };

    networking.firewall.trustedInterfaces = ["cni+" "veth+" "wireguard+" "cilium+" "flannel+" "tun+" "vxlan+" "can+" "lxc+"];
    cilium.enable = lib.mkDefault true;
    # rke2
    services.rke2 = {
      enable = true;
      package = pkgs.rke2_1_34;
      tokenFile = lib.mkDefault "${config.clan.core.vars.generators.rke2.files.token.path}";
      serverAddr = lib.mkDefault "https://${config.keepalived.VIPv4}:9345";
      gracefulNodeShutdown.enable = true;
      cisHardening = true;
      nodeIP = "${config.net.nodeIPv4},${config.net.nodeIPv6}";
      extraFlags = ["--node-external-ip=${config.net.nodeIPv4},${config.net.nodeIPv6}"];
    };
  };
}
