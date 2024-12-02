{
  description = "A developer flake for Dev71's core(71) and clients";

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"

        "aarch64-linux"
        "aarch64-darwin"
      ];
      perSystem =
        {
          lib,
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
                  cc = llvm.stdenv.cc.cc;
                  extraBuildCommands = ''
                    echo "-L${pkgs.libiconv}/lib" >> $out/nix-support/cc-cflags
                    echo "-L${llvm.libcxx}/lib" >> $out/nix-support/cc-cflags
                    echo "-L${pkgs.apple-sdk_15}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.0.sdk/usr/lib/swift" >> $out/nix-support/cc-cflags
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
                  sha256 = "s1RPtyvDGJaX/BisLT+ifVfuhDT1nZkZ1NcK8sbwELM=";
                })
              ];

              inherit (config.treefmt.build.programs) rustfmt;
            };
          };

          devShells.default = mkShell {
            packages = builtins.attrValues {
              buck2 = pkgs.callPackage ./nix/pkgs/buck2 { inherit (fx) fromToolchainFile; };
              inherit (config.treefmt.build.programs) nixfmt buildifier;
            };

            buildInputs = lib.optionals stdenv.isDarwin [ pkgs.apple-sdk_15 ];
            inputsFrom = [ config.devShells.rust ];
          };

        };
      imports = [ ./nix/format-module.nix ];
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
