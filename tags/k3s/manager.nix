{
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [
    ../../disko/manager.nix
  ];
  disko.devices.disk.main.content.partitions.root.size = let
    size =
      if config.k3s.env == "prod"
      then "45G"
      else "25G";
  in
    size;

  k3s.enable = true;
  k3s.manager = true;
  longhorn.enable = true;

  environment.etc = {
    "rancher/k3s/registries.yaml".text = ''
      mirrors:
        "*":
    '';
  };

  # K3s
  services.k3s = {
    role = "server";
    extraFlags = [
      "--embedded-registry"
      "--node-label=role=manager"
      "--tls-san=k3s-${config.k3s.env}"
      "--cluster-cidr=10.42.0.0/16,fd42::/56"
      "--service-cidr=10.43.0.0/16,fd43::/112"
      "--flannel-ipv6-masq"
    ];
  };

  # k3s tailscale service for api
  systemd.services.k3s-api-tailscaled-service = {
    enable = true;
    after = ["tailscaled.service" "k3s.service"];
    wants = ["tailscaled.service" "k3s.service"];
    requires = ["tailscaled.service" "k3s.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
      Restart = "on-failure";
      RestartSec = "45s";
      TimeoutStartSec = "45s";
      ExecStart = [
        "${pkgs-unstable.${pkgs.system}.tailscale}/bin/tailscale serve --service=svc:k3s-${config.k3s.env} --tcp=6443 tcp://localhost:6443"
        "${pkgs-unstable.${pkgs.system}.tailscale}/bin/tailscale serve advertise svc:k3s-${config.k3s.env}"
      ];
      ExecStop = ["${pkgs-unstable.${pkgs.system}.tailscale}/bin/tailscale serve drain svc:k3s-${config.k3s.env}"];
    };
  };
}
