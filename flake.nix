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
          fx = inputs'.fenix.packages;
          toolchains = pkgs.callPackage ./src/build/rust.toolchains.nix {
            inherit (fx) combine;

            inherit (fx.minimal) rustc-unwrapped;
            inherit (fx.complete) rust-src;
          };

          # 16.2: nix store add --hash-algo sha256 /Applications/Xcode.app
          xcode = builtins.fetchClosure {
            fromStore = "https://cache.nixos.org";
            fromPath = /nix/store/npfc6494dw4yz0iiqyi4sfnrwkyc9cyf-Xcode.app;
          };
        in
        {
          packages =
            let
              preludeFor = toolchain: pkgs.callPackage ./src/build/prelude.pkg.nix { inherit toolchain; };

              iosFor =
                target: profile:
                pkgs.callPackage ./src/build/ios.pkg.nix {
                  inherit profile xcode;
                  target =
                    builtins.replaceStrings
                      [
                        "ios"
                        "sim"
                      ]
                      [
                        "ios15.0"
                        "simulator"
                      ]
                      target;

                  prelude =
                    if profile == "debug" then
                      config.packages."prelude-${target}".override { flags = [ "-Cpanic=abort" ]; }
                    else
                      config.packages."prelude-${target}";
                };
            in
            {
              prelude-aarch64-apple-ios = preludeFor toolchains.aarch64-apple-ios;
              prelude-aarch64-apple-ios-sim = preludeFor toolchains.aarch64-apple-ios-sim;

              prelude-aarch64-apple-darwin = preludeFor toolchains.aarch64-apple-darwin;
              prelude-x86_64-unknown-linux-gnu = preludeFor toolchains.x86_64-unknown-linux-gnu;

              ios = iosFor "aarch64-apple-ios" "release";
              ios-sim = pkgs.callPackage ./src/build/ios.simulator.nix rec {
                inherit xcode;
                bundle = iosFor "aarch64-apple-ios-sim" "debug";
                id = bundle.id;
              };
            };

          devShells = rec {
            prelude = config.mk-naked-shell.lib.mkNakedShell {
              name = "dev71";
              packages =
                let
                  toolchain = fx.combine [
                    fx.minimal.rustc-unwrapped
                    fx.complete.rust-src

                    toolchains.aarch64-apple-ios
                    toolchains.aarch64-apple-ios-sim

                    # Testing, constrained by systems attribute
                    (
                      if pkgs.stdenv.isLinux then toolchains.x86_64-unknown-linux-gnu else toolchains.aarch64-apple-darwin
                    )
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
    naked-shell.url = "github:yusdacra/mk-naked-shell";
  };
}
