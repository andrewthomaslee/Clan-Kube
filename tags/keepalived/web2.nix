{...}: {
  keepalived-web = {
    enable = true;
    priority = 190;
    unicastSrcIp = "10.0.0.6";
    unicastPeers = ["10.0.0.5" "10.0.0.7"];
  };
}
