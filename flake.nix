{
  inputs = {
    # Clan.lol
    clan-core = {
      url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rolling Release of Nixpkgs
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    # --- Flakes --- #
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    tailscale = {
      url = "https://github.com/tailscale/tailscale/archive/refs/tags/v1.90.9.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
