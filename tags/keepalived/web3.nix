{...}: {
  keepalived-web = {
    enable = true;
    priority = 180;
    unicastSrcIp = "10.0.0.7";
    unicastPeers = ["10.0.0.6" "10.0.0.5"];
  };
}
