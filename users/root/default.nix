{self, ...}: {
  imports = [
    self.inputs.home-manager.nixosModules.default
    ../../modules
  ];
  #-- Users --#
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  ];
  #-- Home-Manager --#
  home-manager = {
    backupFileExtension = "backup";
    extraSpecialArgs = {inherit (self) inputs;};
    users.root = {
      imports = [
        ./home-configuration.nix
      ];
    };
  };
}
