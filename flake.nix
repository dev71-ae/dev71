{
  description = "A flake for developing, building, and deploying Dev71";

  outputs =
    inputs@{ parts, devshell, ... }:
    parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        {
          pkgs,
          ...
        }:
        let
          inherit (pkgs) callPackage;
        in
        {
          packages.prelude = callPackage ./nix/packages/prelude.nix { };
          devshells.default = import ./nix/shell.nix { inherit pkgs; };
        };

      imports = [
        devshell.flakeModule

        ./nix/darwin-module.nix
        ./nix/format-module.nix
      ];
    };

  inputs = {
    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
}
