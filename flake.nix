{
  # This flake offers no environment whatsoever for the iOS App
  # In fact, people working on the iOS app should refrain from loading the environment.
  # to avoid nix overriding the SDKs & Swift breaking things.
  description = "dev71-ae/dev71: Rust-only flake for building the core of Dev71 clients";

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        pkgs,
        config,
        inputs',
        ...
      }: let
        toolchain = (inputs'.fenix.packages).fromToolchainFile {
          file = ./rust-toolchain.toml;
          sha256 = "yMuSb5eQPO/bHv+Bcf/US8LVMbf/G/0MSfiPwBhiPpk=";
        };
      in {
        devShells.default = pkgs.mkShell {
          packages = builtins.attrValues {
            inherit toolchain;
            inherit (config.treefmt.build.programs) alejandra rustfmt;
          };
        };

        treefmt.config = {
          projectRootFile = "flake.nix";
          flakeFormatter = true;

          programs.alejandra.enable = true;
          programs.rustfmt.enable = true;
        };
      }; # perSystem
      imports = [inputs.treefmt.flakeModule];
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt.url = "github:numtide/treefmt-nix";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
