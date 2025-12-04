{self, ...}: {
  imports = [
    self.inputs.home-manager.nixosModules.default
    ../../modules # DO NOT REMOVE THIS IMPORT!!!
  ];
  #-- Users --#
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOb4q9LWJR54SzRkfmsA5KWA5/SDEG853oFC8TVilCW/"
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
