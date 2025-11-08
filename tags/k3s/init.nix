{...}: {
  # K3s
  services.k3s = {
    clusterInit = true;
    serverAddr = "";
    tokenFile = null;
    extraFlags = [
      "--node-label=init=true"
    ];
  };
}
