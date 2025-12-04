{
  inputs,
  self,
  ...
}: {
  flake = let
    clan = inputs.clan-core.lib.clan {
      inherit self;
      imports = [../clan.nix];
      specialArgs = {inherit inputs;};
    };
  in {
    inherit (clan.config) nixosConfigurations nixosModules clanInternals;
    clan = clan.config;
  };
}
