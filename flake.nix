{
  description = "dev71-ae/dev71: A developer flake for Dev71 clients.";

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          lib,
          pkgs,
          pkgs',
          config,
          inputs',
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            packages =
              builtins.attrValues {
                inherit (pkgs) reindeer;
                inherit (pkgs') buck2 rust-project;

                inherit (pkgs.llvmPackages_latest) clang;
                inherit (config.treefmt.build.programs) nixfmt rustfmt buildifier;

                toolchain-dev =
                  with inputs'.fenix.packages;
                  combine [
                    rust-analyzer
                    complete.rust-src

                    (fromToolchainFile {
                      file = ./rust-toolchain.toml;
                      sha256 = "yMuSb5eQPO/bHv+Bcf/US8LVMbf/G/0MSfiPwBhiPpk=";
                    })
                  ];
              }
              ++ lib.optionals (pkgs.stdenv.isLinux) [ pkgs.mold-wrapped ];
          };

          treefmt.config = {
            projectRootFile = "flake.nix";
            flakeFormatter = true;

            programs.nixfmt.enable = true;
            programs.rustfmt.enable = true;
            programs.buildifier.enable = true;
            programs.biome.enable = true;

            settings.global.excludes = [
              ".buckroot"
              ".buckconfig"
              "*/.buckconfig"
              "build/mode/{debug,release}"
              "build/tools/bin/*"
              "*.{md,toml,envrc,swift}"
            ];

            settings.formatter.buildifier.includes = [
              "BUCK"
              "*/BUCK"
              "PACKAGE"
              "*/PACKAGE"
            ];
          };
        }; # perSystem
      imports = [
        ./nix
        inputs.treefmt.flakeModule
      ];
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt.url = "github:numtide/treefmt-nix";

    fenix = {
      url = "github:nix-community/fenix/monthly";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    buck2-src = {
      url = "github:facebook/buck2";
      flake = false;
    };
  };
}
