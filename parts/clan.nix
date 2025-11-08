{
  inputs,
  self,
  ...
}: {
  flake = let
    pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages;
    pkgs-stable = inputs.nixpkgs-stable.legacyPackages;
    clan = inputs.clan-core.lib.clan {
      inherit self;
      imports = [../clan.nix];
      specialArgs = {inherit inputs pkgs-unstable pkgs-stable;};
    };
  in {
    inherit (clan.config) nixosConfigurations nixosModules clanInternals;
    clan = clan.config;
  };
}
