{
  lib,
  config,
  ...
}: {
  k3s.env = "dev";
  keepalived-web.floatingIPv6-dev = "";
}
