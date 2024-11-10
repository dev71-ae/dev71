{
  description = "dev71-ae/dev71: A native client monorepo for Dev71 with a shared core written in Zig";

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShell {
          packages = builtins.attrValues {
            inherit (pkgs) zig zls;
          };
        };

        treefmt.config = {
          projectRootFile = "flake.nix";
          flakeFormatter = true;

          programs.alejandra.enable = true;
          programs.zig.enable = true;
        };
      }; # perSystem
      imports = [inputs.treefmt.flakeModule];
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt.url = "github:numtide/treefmt-nix";
  };
}
