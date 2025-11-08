{
  config,
  pkgs,
  lib,
  pkgs-unstable,
  ...
}: {
  options.tailscale-server.enable = lib.mkEnableOption "tailscale exit node";

  config = lib.mkIf config.tailscale-server.enable {
    clan.core.vars.generators.tailscale = {
      share = true;
      prompts = {
        auth_key = {
          description = "Tailscale Client Auth Key";
          type = "line";
          persist = true;
        };
      };
      files = {
        "auth_key" = {
          mode = "0400";
        };
      };
    };

    services.tailscale = {
      enable = true;
      package = pkgs-unstable.${pkgs.system}.tailscale;
      openFirewall = true;
      permitCertUid = "andrewthomaslee.business@gmail.com";
      authKeyFile = config.clan.core.vars.generators.tailscale.files."auth_key".path;
      authKeyParameters.ephemeral = false;
      authKeyParameters.preauthorized = true;
      useRoutingFeatures = "server";
      extraUpFlags = [
        "--advertise-exit-node"
        "--accept-routes"
        "--advertise-tags=tag:clan-net"
      ];
    };
    networking = {
      networkmanager.unmanaged = ["tailscale0"];
      firewall.trustedInterfaces = ["tailscale0"];
    };
    services.networkd-dispatcher = {
      enable = true;
      rules."50-tailscale" = {
        onState = ["routable"];
        script = ''
          NETDEV=$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")
          ${pkgs.ethtool}/bin/ethtool -K "$NETDEV" rx-udp-gro-forwarding on rx-gro-list off
        '';
      };
    };
    systemd.services.tailscaled = {
      after = ["network-online.target"];
      wants = ["network-online.target"];
    };
  };
}
