{
  lib,
  config,
  ...
}: {
  imports = [
    ./rke2.nix
    ./longhorn
    ./cilium
  ];
  #-- Kubernetes --#
  rke2 = {
    enable = lib.mkDefault false;
    manager = lib.mkDefault false;
  };
  # --- Deployments --- #
  longhorn = {
    enable = lib.mkDefault false;
    disks.longhorn-00.enable = lib.mkDefault false;
  };
  cilium.enable = lib.mkDefault true;
}
