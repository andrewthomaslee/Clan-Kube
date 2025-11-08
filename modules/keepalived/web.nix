{
  config,
  pkgs,
  lib,
  pkgs-unstable,
  ...
}: {
  options.keepalived-web = {
    enable = lib.mkEnableOption "keepalived-web with floating IPs";
    "floatingIPv6-${config.k3s.env}" = lib.mkOption {
      type = lib.types.str;
      description = "Floating IPv6 address";
    };
    priority = lib.mkOption {
      type = lib.types.int;
      description = "Priority of the VIP";
    };
    unicastSrcIp = lib.mkOption {
      type = lib.types.str;
      description = "Unicast source IP";
    };
    unicastPeers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Unicast peers";
    };
  };

  config = lib.mkIf config.keepalived-web.enable {
    clan.core.vars.generators."keepalived-${config.k3s.env}" = {
      share = true;
      prompts = {
        hetzner-api-token = {
          description = "Hetzner Cloud API Token";
          type = "line";
          persist = true;
        };
      };
      files = {
        hetzner-api-token = {};
      };
    };

    networking.interfaces.eth0.ipv6.addresses = [
      {
        address = config.keepalived-web."floatingIPv6-${config.k3s.env}";
        prefixLength = 64;
      }
    ];

    systemd.services.keepalived = {
      after = ["network-online.target" "tailscaled.service" "k3s.service"];
      wants = ["network-online.target" "tailscaled.service" "k3s.service"];
    };

    services.keepalived = let
      hcloud-ip = pkgs.stdenv.mkDerivation {
        name = "hcloud-ip-linux64";
        src = pkgs.fetchurl {
          url = "https://github.com/FootprintDev/hcloud-ip/releases/download/v0.0.1/hcloud-ip-linux64";
          sha256 = "0dvl3qp4cvx994b5jkl7x99fpn5b1vh1gpbja7cdsixmgjyrgc2r";
        };
        unpackPhase = "true";
        installPhase = ''
          mkdir -p $out/bin
          cp $src $out/bin/hcloud-ip
          chmod +x $out/bin/hcloud-ip
        '';
      };
      failoverScript = pkgs.writeShellApplication {
        name = "failover";
        runtimeInputs = [hcloud-ip];
        text = ''
          IP="web-${config.k3s.env}"
          TOKEN=$(cat ${config.clan.core.vars.generators."keepalived-${config.k3s.env}".files.hetzner-api-token.path})

          n=0
          while [ $n -lt 15 ]
          do
              if [ "$(hcloud-ip -ip "$IP" -key "$TOKEN")" == "Server called $HOSTNAME was found" ]; then
                  break
              fi
              n=$((n+1))
              sleep 5
          done
        '';
      };
      k3sStatus = pkgs.writeShellApplication {
        name = "k3sStatus";
        text = ''
          if systemctl is-active --quiet k3s.service; then
            echo "k3s.service is active and running."
          else
            echo "k3s.service is not active."
            exit 1
          fi

          if systemctl is-active --quiet network-online.target; then
            echo "network-online.target is active and running."
          else
            echo "network-online.target is not active."
            exit 1
          fi

          if systemctl is-active --quiet tailscaled.service; then
            echo "tailscaled.service is active and running."
          else
            echo "tailscaled.service is not active."
            exit 1
          fi
        '';
      };
    in {
      enable = true;
      openFirewall = true;
      extraGlobalDefs = ''
        use_symlink_paths true
        max_auto_priority 1
      '';
      vrrpScripts = {
        k3sStatus = {
          script = "${k3sStatus}/bin/k3sStatus";
          interval = 60;
          user = "root";
        };
      };
      vrrpInstances.K3S_1 = {
        priority = config.keepalived-web.priority;
        unicastSrcIp = config.keepalived-web.unicastSrcIp;
        unicastPeers = config.keepalived-web.unicastPeers;
        interface = "enp7s0";
        virtualRouterId = 1;
        trackScripts = ["k3sStatus"];
        trackInterfaces = ["tailscale0" "eth0"];
        extraConfig = ''
          notify_master ${failoverScript}/bin/failover
        '';
      };
    };
  };
}
