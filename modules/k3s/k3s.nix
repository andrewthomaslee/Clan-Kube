{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: {
  options.k3s = {
    enable = lib.mkEnableOption "k3s";
    manager = lib.mkOption {
      type = lib.types.bool;
      description = "Enable k3s manager";
      default = false;
    };
    env = lib.mkOption {
      type = lib.types.str;
      description = "dev/prod";
      default = "dev";
    };
    IPv4 = lib.mkOption {
      type = lib.types.str;
      description = "Private IPv4 Address";
    };
    IPv6 = lib.mkOption {
      type = lib.types.str;
      description = "Public IPv6 Address";
    };
  };

  config = lib.mkIf config.k3s.enable {
    clan.core.vars.generators."k3s-${config.k3s.env}" = {
      share = true;
      prompts = {
        "token" = {
          persist = true;
          type = "line";
          description = ''
            K3s Token
          '';
          display.group = "k3s";
        };
      };
      files = {
        "token" = {};
      };
    };

    # Networking
    networking.firewall = {
      trustedInterfaces = ["enp7s0" "flannel.1" "cni0"];
      interfaces.eth0 = {
        allowedTCPPorts = lib.optionals (!config.k3s.manager) [80 443] ++ lib.optionals config.k3s.manager [6443];
      };
    };

    systemd.services.k3s = {
      after = ["network-online.target" "tailscaled.service"];
      wants = ["network-online.target" "tailscaled.service"];
    };

    # k3s
    services.k3s = {
      enable = true;
      package = pkgs-unstable.${pkgs.system}.k3s;
      tokenFile = lib.mkDefault "${config.clan.core.vars.generators."k3s-${config.k3s.env}".files.token.path}";
      serverAddr = lib.mkDefault "https://10.0.0.2:6443";
      gracefulNodeShutdown.enable = true;
      extraFlags = [
        "--flannel-iface=enp7s0"
        "--node-ip=${config.k3s.IPv4},${config.k3s.IPv6}"
      ];
    };
  };
}
