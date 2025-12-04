{
  config,
  lib,
  pkgs,
  ...
}: {
  options.net = {
    enable = lib.mkEnableOption "network settings service";
    iface = lib.mkOption {
      type = lib.types.str;
      description = "Network Interface";
      default = "eno1";
    };
    IPv4 = lib.mkOption {
      type = lib.types.str;
      description = "IPv4 Public Address";
    };
    IPv6 = lib.mkOption {
      type = lib.types.str;
      description = "IPv6 Public Address";
    };
    nodeIPv4 = lib.mkOption {
      type = lib.types.str;
      description = "IPv4 Private Address";
    };
    nodeIPv6 = lib.mkOption {
      type = lib.types.str;
      description = "IPv6 Private Address";
    };
  };

  config = lib.mkIf config.net.enable {
    # Networking
    services.fail2ban.enable = lib.mkForce true;
    networking = {
      firewall = {
        enable = lib.mkDefault true;
        pingLimit = "--limit 1/minute --limit-burst 5";
        trustedInterfaces = ["${config.net.iface}.4000"];
        allowedTCPPorts = [22 80 443];
      };
      useNetworkd = true;
      defaultGateway6 = {
        address = "fe80::1";
        interface = "${config.net.iface}";
      };
      # Public Interface
      interfaces."${config.net.iface}" = {
        useDHCP = true;
        wakeOnLan.enable = true;
        ipv6.addresses = [
          {
            address = "${config.net.IPv6}";
            prefixLength = 64;
          }
        ];
      };
      # vSwitch
      vlans = {
        "${config.net.iface}.4000" = {
          id = 4000;
          interface = "${config.net.iface}";
        };
      };
      interfaces."${config.net.iface}.4000" = {
        mtu = 1400;
        ipv4.addresses = [
          {
            address = "${config.net.nodeIPv4}";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = "${config.net.nodeIPv6}";
            prefixLength = 64;
          }
        ];
      };
    };

    systemd.network = {
      enable = true;
      wait-online.enable = lib.mkForce true;
    };

    services.resolved = {enable = true;};
  };
}
