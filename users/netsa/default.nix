{self, ...}: {
  imports = [
    self.inputs.home-manager.nixosModules.default
  ];
  #-- Users --#
  users.users.netsa.openssh.authorizedKeys.keys = [
    "ssh-ed25519 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  ];
  #-- Home-Manager --#
  home-manager = {
    backupFileExtension = "backup";
    extraSpecialArgs = {inherit (self) inputs;};
    users.netsa = {
      imports = [
        ./home-configuration.nix
      ];
    };
  };

  #-- Nix --#
  nix.settings.trusted-users = ["netsa"];
}
