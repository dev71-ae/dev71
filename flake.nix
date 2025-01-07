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
          packages = import ./package.nix;

          inherit (pkgs) lib stdenv callPackage;
          mkNakedShell = callPackage inputs.naked-shell { };
        in
        {
          packages = {
            prelude = callPackage packages.prelude { };
            ios = callPackage packages.ios { xcode = 0; };
          };

          apps.xcgen = {
            type = "app";
            program = lib.getExe (
              pkgs.writeShellApplication {
                name = "xcgen";
                runtimeInputs = [
                  pkgs.zig
                  pkgs.zls
                  pkgs.tuist
                ];
                text = ''
                  zig build ios
                  TUIST_ZIG=${lib.getExe pkgs.zig} tuist generate
                '';
              }
            );
          };

          devShells.default = mkNakedShell {
            name = "dev71-shell";
            packages = [
              pkgs.zig
              pkgs.zls
            ] ++ lib.optionals stdenv.isDarwin [ pkgs.tuist ];
          };
        };

      imports = [ ./treefmt.nix ];
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
