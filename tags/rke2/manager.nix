{
  config,
  pkgs,
  inputs,
  ...
}: let
  tailscale = inputs.tailscale.packages.${pkgs.stdenv.hostPlatform.system}.tailscale;
in {
  rke2.enable = true;
  rke2.manager = true;
  # --- Networking --- #
  haproxy.enable = true;
  keepalived.enable = true;
  # --- Deployments --- #
  longhorn = {
    enable = true;
    disks = {
      longhorn-00.enable = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      kubectl
      kubernetes-helm
      argocd
    ];
    etc = {
      "rancher/rke2/registries.yaml" = {
        text = ''
          mirrors:
            "*":
        '';
      };
    };
  };

  # rke2
  services.rke2 = {
    role = "server";
    nodeLabel = ["role=manager"];
    disable = ["rke2-ingress-nginx"];
    extraFlags = [
      "--embedded-registry"
      "--tls-san=rke2-api"
      "--tls-san=${config.keepalived.VIPv4}"
      "--cluster-cidr=${config.rke2.ipv4-cluster-cidr},${config.rke2.ipv6-cluster-cidr}"
      "--service-cidr=${config.rke2.ipv4-service-cidr},${config.rke2.ipv6-service-cidr}"
      "--profile=cis"
      "--enable-servicelb"
      "--ingress-controller=none"
    ];
  };

  # rke2 tailscale service for api
  systemd.services.rke2-api-tailscaled-service = {
    enable = true;
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
      Restart = "on-failure";
      RestartSec = "45s";
      TimeoutStartSec = "45s";
      ExecStart = [
        "${tailscale}/bin/tailscale serve --service=svc:rke2-api --tcp=6443 tcp://localhost:6443"
        "${tailscale}/bin/tailscale serve advertise svc:rke2-api"
      ];
      ExecStop = ["${tailscale}/bin/tailscale serve drain svc:rke2-api"];
    };
  };
}
