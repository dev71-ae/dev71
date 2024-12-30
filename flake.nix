{
  description = "A flake for developing, building, and deploying Dev71";

  outputs =
    inputs@{
      parts,
      treefmt,
      naked-shell,
      ...
    }:
    parts.lib.mkFlake { inherit inputs; } {
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
          inherit (pkgs) stdenv;
        in
        {
          packages.prelude = pkgs.callPackage (
            {
              target ? "aarch64-apple-ios-sim",
            }:
            stdenv.mkDerivation {
              pname = "dev71-prelude";
              version = "0.1.0";

              nativeBuildInputs =
                let
                  rustc = fx.minimal.rustc-unwrapped;

                  rustlibs = pkgs.callPackage ./rustlibs.nix {
                    inherit rustc;
                    inherit (fx.complete) rust-src;

                    fenix = fx;
                  } target;

                  toolchain = fx.combine [
                    rustc
                    rustlibs
                  ];
                in
                [ toolchain ];
            }
          ) { };

          devShells.prelude = config.mk-naked-shell.lib.mkNakedShell {
            name = "dev71";

            packages = [
              fx.rust-analyzer
              config.treefmt.build.programs.rustfmt
            ] ++ config.packages.prelude.nativeBuildInputs;
          };

          apps.simulator = { };

          treefmt.config = {
            projectRootFile = "flake.nix";

            flakeCheck = true;
            flakeFormatter = true;

            # .nix
            programs.nixfmt.enable = true;

            # .h
            programs.clang-format.enable = true;

            # .sh
            programs.shellcheck.enable = true;

            # .rs
            programs.rustfmt = {
              enable = true;
              package = fx.complete.rustfmt;
            };

            settings.global.excludes = [
              "*.{md,swift,envrc,kt}"
            ];
          };

          packages.default = config.packages.prelude;
          devShells.default = config.devShells.prelude;
        };

      imports = [
        treefmt.flakeModule
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
