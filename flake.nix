{
  description = "A flake for developing, building, and deploying Dev71";

  outputs =
    inputs@{ parts, ... }:
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
          devShells.default = callPackage ./nix/shell.nix {
            mkNakedShell = callPackage inputs.naked-shell { };
          };

          packages.prelude = callPackage ./nix/packages/prelude.nix { };
        };

      imports = [
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

    naked-shell = {
      url = "github:yusdacra/mk-naked-shell";
      flake = false;
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
}
