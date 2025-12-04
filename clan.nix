{
  meta.name = "Clan-Net";

  inventory.machines = {
    #------- Cluster -------#
    hel-m-0 = {
      deploy.targetHost = "root@hel-m-0";
      tags = ["helsinki" "manager" "init"];
    };
    hel-m-1 = {
      deploy.targetHost = "root@hel-m-1";
      tags = ["helsinki" "manager"];
    };
    hel-m-2 = {
      deploy.targetHost = "root@hel-m-2";
      tags = ["helsinki" "manager"];
    };
  };

  # Docs: https://docs.clan.lol/services/definition/
  inventory.instances = {
    # Docs: https://docs.clan.lol/services/official/admin/
    admin = {
      roles.default = {
        tags.all = {};
        settings.allowedKeys = {Clan-Net = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOb4q9LWJR54SzRkfmsA5KWA5/SDEG853oFC8TVilCW/";};
        extraModules = [./users/root];
      };
    };
    # Docs: https://docs.clan.lol/services/official/users/
    netsa = {
      module.name = "users";
      roles.default = {
        tags.all = {};
        settings = {
          user = "netsa";
          prompt = false;
          groups = ["wheel" "networkmanager"];
        };
        extraModules = [./users/netsa];
      };
    };

    #----------- Tags -----------#
    #--- Every Machine ---#
    base = {
      module.name = "importer";
      roles.default.tags.all = {};
      roles.default.extraModules = [./tags/base.nix];
    };
    #------- Location -------#
    helsinki = {
      module.name = "importer";
      roles.default.tags.helsinki = {};
      roles.default.extraModules = [./tags/location/helsinki.nix];
    };
    #----------- rke2 -----------#
    # rke2 First Node
    init = {
      module.name = "importer";
      roles.default.tags.init = {};
      roles.default.extraModules = [./tags/rke2/init.nix];
    };
    # rke2 Manager Node
    manager = {
      module.name = "importer";
      roles.default.tags.manager = {};
      roles.default.extraModules = [./tags/rke2/manager.nix];
    };
  };
  #-------------- Machine Configuration -------------#
  machines = {
    hel-m-0 = {...}: {
      net = {
        IPv4 = "0"; # REDACTED
        IPv6 = "0"; # REDACTED
        nodeIPv4 = "10.0.42.2";
        nodeIPv6 = "fd08:2024:abba::2";
      };
      keepalived = {
        priority = 200;
        unicastPeers = ["10.0.42.3" "10.0.42.4"];
      };
    };
    hel-m-1 = {...}: {
      net = {
        IPv4 = "0"; # REDACTED
        IPv6 = "0"; # REDACTED
        nodeIPv4 = "10.0.42.3";
        nodeIPv6 = "fd08:2024:abba::3";
      };
      keepalived = {
        priority = 190;
        unicastPeers = ["10.0.42.2" "10.0.42.4"];
      };
    };
    hel-m-2 = {...}: {
      net = {
        IPv4 = "0"; # REDACTED
        IPv6 = "0"; # REDACTED
        nodeIPv4 = "10.0.42.4";
        nodeIPv6 = "fd08:2024:abba::4";
      };
      keepalived = {
        priority = 180;
        unicastPeers = ["10.0.42.3" "10.0.42.2"];
      };
    };
  };
}
