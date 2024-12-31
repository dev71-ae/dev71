{
  description = "A flake for developing, building, and deploying Dev71";

  outputs =
    inputs@{
      parts,
      naked-shell,
      ...
    }:
    parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      perSystem =
        {
          pkgs,
          config,
          inputs',
          ...
        }:
        let
          inherit (pkgs) lib;
          fx = inputs'.fenix.packages;
        in
        {
          packages =
            let
              prelude =
                target:
                pkgs.callPackage ./src/build/prelude.pkg.nix {
                  fenix = fx;
                  rustc-target = target;
                };

              ios = pkgs.callPackage ./src/build/ios.pkg.nix;
            in
            {
              prelude-aarch64-apple-ios = prelude "aarch64-apple-ios";
              prelude-aarch64-apple-ios-sim = prelude "aarch64-apple-ios-sim";
              prelude-x86_64-unknown-linux-gnu = prelude "x86_64-unknown-linux-gnu";

              ios = ios {
                swiftc-target = "aarch64-apple-ios15.0";
                prelude = config.packages."prelude-aarch64-apple-ios";
              };

              ios-sim = ios {
                swiftc-target = "aarch64-apple-ios15.0-simulator";
                prelude = config.packages."prelude-aarch64-apple-ios-sim".override {
                  rustc-flags = [ "-Cpanic=abort" ];
                };
              };
            };

          devShells = rec {
            prelude = config.mk-naked-shell.lib.mkNakedShell {
              name = "dev71";
              packages =
                let
                  p = config.packages;
                  toolchain = fx.combine [
                    fx.minimal.rustc
                    fx.complete.rust-src

                    p.prelude-aarch64-apple-ios.rustlibs.core
                    p.prelude-aarch64-apple-ios.rustlibs.compiler-builtins

                    p.prelude-aarch64-apple-ios-sim.rustlibs.core
                    p.prelude-aarch64-apple-ios-sim.rustlibs.compiler-builtins

                    p.prelude-x86_64-unknown-linux-gnu.rustlibs.core
                    p.prelude-x86_64-unknown-linux-gnu.rustlibs.compiler-builtins

                  ];
                in
                [
                  toolchain
                  fx.rust-analyzer
                  config.treefmt.build.programs.rustfmt
                ];
            };

            default = prelude;
          };

          apps.run-ios-sim = {
            type = "app";
            program =
              let
                drv = pkgs.writeShellApplication {
                  name = "run-ios-sim";
                  text = ''
                    if [ "''${1:-}" = "boot" ]; then
                      DEVICE="''${2:-iPhone 16 Pro Max}"
                      xcrun simctl boot "$DEVICE"
                    fi

                    open -a "Simulator.app"

                    xcrun simctl install booted ${config.packages.ios-sim}/Applications/Dev71.app
                    xcrun simctl launch booted ae.dev71.Dev71
                  '';

                  meta.platforms = lib.platforms.darwin;
                };
              in
              "${drv}/bin/${drv.name}";
          };
        };

      imports = [
        ./treefmt.nix
        naked-shell.flakeModule
      ];
    };

  inputs = {
    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # TODO: Integrate something like this into the repo.
    naked-shell.url = "github:yusdacra/mk-naked-shell";
  };
}
