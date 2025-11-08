{...}: {
  keepalived-web = {
    enable = true;
    priority = 200;
    unicastSrcIp = "10.0.0.5";
    unicastPeers = ["10.0.0.6" "10.0.0.7"];
  };
}
