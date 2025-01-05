{
  description = "A flake for developing, building, and deploying Dev71 clients and services";

  outputs =
    inputs@{
      parts,
      naked-shell,
      ...
    }:
    parts.lib.mkFlake { inherit inputs; } (
      { withSystem, ... }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-darwin"
        ];
        perSystem =
          {
            pkgs,
            config,
            ...
          }:
          {
            packages = {
              prelude = pkgs.callPackage ./src/drv/prelude.nix { };
            };

            devShells = rec {
              prelude = config.mk-naked-shell.lib.mkNakedShell {
                name = "dev71";
                packages = builtins.attrValues {
                  inherit (pkgs) zig zls;
                };
              };

              default = prelude;
            };
          };

        flake.packages.aarch64-darwin = withSystem "aarch64-darwin" (
          { pkgs, ... }:
          let
            # 16.2: nix store add --hash-algo sha256 /Applications/Xcode.app
            xcode = builtins.fetchClosure {
              fromStore = "https://cache.nixos.org";
              fromPath = /nix/store/npfc6494dw4yz0iiqyi4sfnrwkyc9cyf-Xcode.app;
            };

            iosFor =
              target: profile:
              pkgs.callPackage ./src/drv/dev71.nix {
                inherit xcode;
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
              };
          in
          {
            ios = iosFor "aarch64-apple-ios" "release";
            ios-sim = pkgs.callPackage ./src/drv/simulator.nix rec {
              inherit xcode;
              bundle = iosFor "aarch64-apple-ios-sim" "debug";
              name = bundle.data.EXECUTABLE_NAME;
              id = bundle.data.PRODUCT_BUNDLE_IDENTIFIER;
            };
          }
        );

        imports = [
          ./treefmt.nix
          naked-shell.flakeModule
        ];
      }
    );

  inputs = {
    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    naked-shell.url = "github:yusdacra/mk-naked-shell";
  };
}
