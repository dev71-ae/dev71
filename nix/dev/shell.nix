{
  pkgs ? atom.pkgs,
  fenix ? atom.fenix,
}:
let
  inherit (pkgs) lib stdenv;
  toolchain = fenix.fromToolchainFile { file = "${mod}/rust-toolchain"; };
in
pkgs.mkShell {
  RUST_SRC_PATH = "${toolchain}/lib/rustlib/src/rust/library";
  packages = builtins.attrValues {
    inherit toolchain;
    inherit (pkgs)
      starpls
      buildifier
      bazel_7
      perl
      ;

    inherit (fenix) rust-analyzer;
    inherit (fenix.default) rustfmt clippy;
  };
}
