{
  perSystem =
    {
      pkgs,
      config,
      inputs',
      ...
    }:
    let
      fx = inputs'.fenix.packages;
      inherit (pkgs) lib stdenv;
    in
    {
      packages.bso =
        let
          toolchain =
            with fx;
            combine [
              minimal.rustc
              minimal.cargo
            ];

          rustPlatform = pkgs.makeRustPlatform {
            rustc = toolchain;
            cargo = toolchain;
          };
        in
        rustPlatform.buildRustPackage {
          pname = "bso";
          version = "0.1.0";

          src = ./.;

          buildInputs = lib.optionals stdenv.isDarwin [ pkgs.libiconv ];
          cargoLock.lockFile = ./Cargo.lock;
        };

      devShells.bso = pkgs.mkShell {
        inputsFrom = [ config.packages.bso ];

        packages = [
          fx.rust-analyzer
          config.treefmt.build.programs.rustfmt
        ];

        RUST_SRC_PATH = "${fx.complete.rust-src}/lib/rustlib/src/rust/library";
      };
    };
}
