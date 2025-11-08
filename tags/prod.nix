{lib, ...}: {
  k3s.env = "prod";
  keepalived-web.floatingIPv6-prod = "";
}
