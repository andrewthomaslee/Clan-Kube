{
  config,
  lib,
  pkgs,
  ...
}: let
  iface = "${config.net.iface}.4000";
  mtu = "${builtins.toString config.networking.interfaces.${iface}.mtu}";
  cilium-config = pkgs.writeText "cilium-config.yaml" ''
    apiVersion: helm.cattle.io/v1
    kind: HelmChartConfig
    metadata:
      name: rke2-cilium
      namespace: kube-system
    spec:
      valuesContent: |-
        devices: "${iface}"
        MTU: ${mtu}

        ipv6:
          enabled: true

        ipv4NativeRoutingCIDR: "${config.rke2.ipv4-cluster-cidr}"
        ipv6NativeRoutingCIDR: "${config.rke2.ipv6-cluster-cidr}"

        kubeProxyReplacement: true
        k8sServiceHost: "localhost"
        k8sServicePort: "6443"

        ipam:
          mode: "kubernetes"
          operator:
            clusterPoolIPv4PodCIDRList: ["${config.rke2.ipv4-cluster-cidr}"]
            clusterPoolIPv6PodCIDRList: ["${config.rke2.ipv6-cluster-cidr}"]

        operator:
          replicas: 1

        hubble:
          enabled: true
          relay:
            enabled: true
          ui:
            enabled: true
  '';
in {
  options.cilium = {
    enable = lib.mkEnableOption "cilium";
  };

  config = lib.mkIf config.cilium.enable {
    networking = {
      firewall.checkReversePath = "loose";
    };
    # rke2
    services.rke2 = lib.mkIf config.rke2.manager {
      extraFlags = ["--disable-kube-proxy"];
      cni = "cilium";
      manifests = {
        cilium-config.source = cilium-config;
      };
    };
  };
}
