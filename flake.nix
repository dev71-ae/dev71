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
          pkgs,
          config,
          inputs',
          ...
        }:
        let
          fx = inputs'.fenix.packages;
          llvm = pkgs.llvmPackages_19;

          stdenv =
            if pkgs.stdenv.isDarwin then
              llvm.stdenv.override {
                cc = pkgs.wrapCCWith {
                  cc = llvm.stdenv.cc;
                  extraBuildCommands = ''
                    echo "-L${pkgs.libiconv}/lib" >> $out/nix-support/cc-cflags
                  '';
                };
              }
            else
              pkgs.stdenvAdapters.useMoldLinker llvm.stdenv;

          mkShell = pkgs.mkShell.override { inherit stdenv; };
        in
        {

          devShells.rust = mkShell {
            packages = builtins.attrValues {
              rust-toolchain = fx.combine [
                fx.rust-analyzer
                fx.complete.rust-src

                (fx.fromToolchainFile {
                  file = ./rust-toolchain.toml;
                  sha256 = "yMuSb5eQPO/bHv+Bcf/US8LVMbf/G/0MSfiPwBhiPpk=";
                })
              ];

              inherit (config.treefmt.build.programs) rustfmt;
            };
          };

          devShells.default = mkShell {
            inputsFrom = [ config.devShells.rust ];
            packages = builtins.attrValues {
              buck2 = pkgs.callPackage ./dev/nix/pkgs/buck2 { inherit (fx) fromToolchainFile; };
              inherit (config.treefmt.build.programs) nixfmt buildifier;
            };
          };

        };
      imports = [ ./dev/nix/format-module.nix ];
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
