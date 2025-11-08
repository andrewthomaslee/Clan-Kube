{
  inputs = {
    # Clan.lol
    clan-core = {
      url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
      inputs.flake-parts.follows = "flake-parts";
    };

    # pkgs
    nixpkgs.follows = "clan-core/nixpkgs";

    # Rolling Release of Nixpkgs
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    # Stable Release of Nixpkgs (25.05)
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";

    # Home-Manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake Parts
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    #--- My Flakes ---#
  };
  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} ({
      self,
      pkgs,
      ...
    }: {
      systems = [
        "x86_64-linux"
      ];

      imports = [
        ./parts/devShell.nix
        ./parts/apps.nix
        ./parts/clan.nix
      ];
    });
}
