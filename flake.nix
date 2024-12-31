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
          fs = lib.fileset;
        in
        {
          packages =
            let
              ios-app =
                {
                  xcode ? builtins.fetchClosure {
                    fromStore = "https://cache.nixos.org";
                    fromPath = /nix/store/npfc6494dw4yz0iiqyi4sfnrwkyc9cyf-Xcode.app;
                  },
                  target,
                }:
                let
                  xctoolchain = "${xcode}/Contents/Developer/Toolchains/XcodeDefault.xctoolchain";
                  isSimulator = lib.hasSuffix "simulator" target;
                in
                pkgs.stdenvNoCC.mkDerivation {
                  pname = "dev71-ios";
                  version = "0.1.0";

                  preferLocalBuild = true;

                  src = fs.toSource {
                    root = ./.;
                    fileset = fs.unions [
                      ./data/Info.plist
                      ./src/Main.swift
                    ];
                  };

                  buildInputs =
                    let
                      prelude =
                        if isSimulator then
                          config.packages."prelude-aarch64-apple-ios-sim".override { rustc-flags = [ "-Cpanic=abort" ]; }
                        else
                          config.packages."preldue-aarch64-apple-ios";
                    in
                    [ prelude ];

                  configurePhase =
                    let
                      platform = if isSimulator then "iPhoneSimulator" else "iPhoneOS";
                    in
                    ''
                      export SDKROOT="${xcode}/Contents/Developer/Platforms/${platform}.platform/Developer/SDKs/${platform}.sdk"
                    '';

                  buildPhase = ''
                    ${xctoolchain}/usr/bin/swiftc ./src/Main.swift \
                                          		    -target ${target} \
                                          		    -sdk "$SDKROOT" \
                                          		    -o Dev71
                  '';

                  installPhase = ''
                    mkdir -p $out/Applications/Dev71.app

                    cp ./data/Info.plist $out/Applications/Dev71.app 
                    cp Dev71 $out/Applications/Dev71.app
                  '';
                };
            in
            {
              ios-app = ios-app { target = "aarch64-apple-ios18.2"; };
              ios-app-sim = ios-app { target = "aarch64-apple-ios18.2-simulator"; };
            }
            //
              lib.foldl'
                (
                  acc: target:
                  acc
                  // {
                    "prelude-${target}" = pkgs.callPackage ./prelude.pkg.nix {
                      fenix = fx;
                      rustc-target = target;
                    };
                  }
                )
                { }
                [
                  "aarch64-apple-ios"
                  "aarch64-apple-ios-sim"
                ];

          devShells.prelude = config.mk-naked-shell.lib.mkNakedShell {
            name = "dev71";

            packages = [
              fx.rust-analyzer
              config.treefmt.build.programs.rustfmt
            ];
          };

          apps.ios-sim = {
            type = "app";
            program = lib.getExe (
              pkgs.writeShellApplication {
                name = "ios-sim";

                text = ''
                  if [ "''${1:-}" = "boot" ]; then
                    DEVICE="''${2:-iPhone 16 Pro Max}"
                    xcrun simctl boot "$DEVICE"
                  fi

                  open -a "Simulator.app"

                  xcrun simctl install booted ${config.packages.ios-app-sim}/Applications/Dev71.app
                  xcrun simctl launch booted ae.dev71.Dev71
                '';

                meta.mainProgram = "ios-sim";
                meta.platforms = lib.platforms.darwin;
              }
            );
          };

          devShells.default = config.devShells.prelude;
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
