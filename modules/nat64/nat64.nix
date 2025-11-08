{
  config,
  lib,
  pkgs,
  ...
}: let
  # Public NAT64 service https://nat64.net/
  nameserverPrimary =
    if config.time.timeZone == "Europe/Helsinki"
    then "2a01:4f9:c010:3f02::1" # Helsinki
    else if config.time.timeZone == "Europe/Berlin"
    then "2a01:4f8:c2c:123f::1" # Nuremberg
    else "2a01:4f8:c2c:123f::1"; # Default

  nameserverSecondary =
    if nameserverPrimary == "2a01:4f9:c010:3f02::1" # Helsinki
    then "2a01:4f8:c2c:123f::1" # Nuremberg
    else "2a01:4f9:c010:3f02::1"; # Helsinki

  nameserverFallBack = [
    "2a00:1098:2b::1" # Amsterdam
    "2a00:1098:2c::1" # London
  ];
  resolvConfContents = lib.concatStringsSep "\n" (lib.map (ns: "nameserver " + ns) [nameserverPrimary nameserverSecondary]);
  customResolvConf = pkgs.writeText "k3s-resolv.conf" resolvConfContents;
in {
  options.nat64.enable = lib.mkEnableOption "nat64.net service";

  config = lib.mkIf config.nat64.enable {
    systemd.network.enable = true;
    networking = {
      useNetworkd = true;
      nameservers = [nameserverPrimary];
      networkmanager.dns = "none";
    };
    services.resolved = {
      enable = true;
      fallbackDns = [nameserverSecondary] ++ nameserverFallBack;
    };

    services.k3s.extraFlags = [
      "--resolv-conf=${customResolvConf}"
    ];
  };
}
