{
  description = "A flake solely for getting you into an envirornment with buck2 and developer tooling";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, fenix, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"

        "aarch64-darwin"
        "aarch64-linux"
      ];

      forAllSystems =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f system (nixpkgs.legacyPackages.${system}));
    in
    {
      devShells = forAllSystems (
        system: pkgs: {
          default = pkgs.mkShell {
            packages =
              let
                fx = fenix.packages.${system};
              in
              [
                fx.rust-analyzer
                (fx.combine [
                  fx.complete.rust-src
                  fx.stable.rustc
                  fx.stable.cargo
                ])

                (pkgs.callPackage ./pkgs.buck2 { inherit (fx) fromToolchainFile; })
              ];
          };
        }
      );
    };
}
