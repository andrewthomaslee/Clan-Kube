{
  meta.name = "Clan-Net";

  inventory.machines = {
    #------- Dev Cluster -------#
    #--- Helsinki ---#
    hel-d-m = {
      deploy.targetHost = "root@hel-d-m";
      tags = ["dev" "CX33" "helsinki" "manager" "init"];
    };
    hel-d-w = {
      deploy.targetHost = "root@hel-d-w";
      tags = ["dev" "CX23" "helsinki" "worker" "web1"];
    };
    #--- Falkenstein ---#
    fsn-d-m = {
      deploy.targetHost = "root@fsn-d-m";
      tags = ["dev" "CX33" "falkenstein" "manager"];
    };
    fsn-d-w = {
      deploy.targetHost = "root@fsn-d-w";
      tags = ["dev" "CX23" "falkenstein" "worker" "web2"];
    };
    #--- Nuremberg ---#
    nbg-d-m = {
      deploy.targetHost = "root@nbg-d-m";
      tags = ["dev" "CX33" "nuremberg" "manager"];
    };
    nbg-d-w = {
      deploy.targetHost = "root@nbg-d-w";
      tags = ["dev" "CX23" "nuremberg" "worker" "web3"];
    };
    #------- Prod Cluster -------#
    #--- Helsinki ---#
    hel-p-m = {
      deploy.targetHost = "root@hel-p-m";
      tags = ["prod" "CX53" "helsinki" "manager" "init"];
    };
    hel-p-w = {
      deploy.targetHost = "root@hel-p-w";
      tags = ["prod" "CX43" "helsinki" "worker" "web1"];
    };
    #--- Falkenstein ---#
    fsn-p-m = {
      deploy.targetHost = "root@fsn-p-m";
      tags = ["prod" "CX53" "falkenstein" "manager"];
    };
    fsn-p-w = {
      deploy.targetHost = "root@fsn-p-w";
      tags = ["prod" "CX43" "falkenstein" "worker" "web2"];
    };
    #--- Nuremberg ---#
    nbg-p-m = {
      deploy.targetHost = "root@nbg-p-m";
      tags = ["prod" "CX53" "nuremberg" "manager"];
    };
    nbg-p-w = {
      deploy.targetHost = "root@nbg-p-w";
      tags = ["prod" "CX43" "nuremberg" "worker" "web3"];
    };
  };

  # Docs: https://docs.clan.lol/services/definition/
  inventory.instances = {
    # Docs: https://docs.clan.lol/services/official/admin/
    admin = {
      roles.default = {
        tags.all = {};
        settings.allowedKeys = {Clan-Net = "ssh-ed25519 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";};
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
    #--- dev/prod ---#
    dev = {
      module.name = "importer";
      roles.default.tags.dev = {};
      roles.default.extraModules = [./tags/dev.nix];
    };
    prod = {
      module.name = "importer";
      roles.default.tags.prod = {};
      roles.default.extraModules = [./tags/prod.nix];
    };
    #------- Instance Type -------#
    CX23 = {
      module.name = "importer";
      roles.default.tags.CX23 = {};
      roles.default.extraModules = [./tags/instanceType/CX23.nix];
    };
    CX33 = {
      module.name = "importer";
      roles.default.tags.CX33 = {};
      roles.default.extraModules = [./tags/instanceType/CX33.nix];
    };
    CX43 = {
      module.name = "importer";
      roles.default.tags.CX43 = {};
      roles.default.extraModules = [./tags/instanceType/CX43.nix];
    };
    CX53 = {
      module.name = "importer";
      roles.default.tags.CX53 = {};
      roles.default.extraModules = [./tags/instanceType/CX53.nix];
    };
    #------- Location -------#
    helsinki = {
      module.name = "importer";
      roles.default.tags.helsinki = {};
      roles.default.extraModules = [./tags/location/helsinki.nix];
    };
    nuremberg = {
      module.name = "importer";
      roles.default.tags.nuremberg = {};
      roles.default.extraModules = [./tags/location/nuremberg.nix];
    };
    falkenstein = {
      module.name = "importer";
      roles.default.tags.falkenstein = {};
      roles.default.extraModules = [./tags/location/falkenstein.nix];
    };
    #----------- K3s -----------#
    # K3s First Node
    init = {
      module.name = "importer";
      roles.default.tags.init = {};
      roles.default.extraModules = [./tags/k3s/init.nix];
    };
    # K3s Manager Node
    manager = {
      module.name = "importer";
      roles.default.tags.manager = {};
      roles.default.extraModules = [./tags/k3s/manager.nix];
    };
    # K3s Worker Node
    worker = {
      module.name = "importer";
      roles.default.tags.worker = {};
      roles.default.extraModules = [./tags/k3s/worker.nix];
    };
    #--- keepalived ---#
    web1 = {
      module.name = "importer";
      roles.default.tags.web1 = {};
      roles.default.extraModules = [./tags/keepalived/web1.nix];
    };
    web2 = {
      module.name = "importer";
      roles.default.tags.web2 = {};
      roles.default.extraModules = [./tags/keepalived/web2.nix];
    };
    web3 = {
      module.name = "importer";
      roles.default.tags.web3 = {};
      roles.default.extraModules = [./tags/keepalived/web3.nix];
    };
  };
}
