{...}: {
  nixpkgs.hostPlatform = "x86_64-linux";
  services.k3s.extraFlags = [
    "--node-label=instanceType=CX23"
  ];
}
