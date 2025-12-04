{...}: {
  # rke2
  services.rke2 = {
    serverAddr = "";
    tokenFile = null;
    nodeLabel = ["init=true"];
  };
}
