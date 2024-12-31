{
  lib,
  stdenv,
  fetchFromGitHub,
  rustc-unwrapped,
  rust-src,
  combine,
}:
let
  toolchain =
    target:
    let
      flags = [
        "-Cpanic=abort"
        "-Copt-level=2"
        "-Zforce-unstable-if-unmarked"
      ];

      featuresToCfg = lib.concatMapStringsSep " " (feature: "--cfg=feature='\"${feature}\"'");

      core =
        let
          features = featuresToCfg [
            "optimize_for_size"
            "panic_immediate_abort"
          ];
        in
        stdenv.mkDerivation {
          pname = "core-${target}";
          version = rust-src.version;

          src = rust-src;

          nativeBuildInputs = [ rustc-unwrapped ];

          buildPhase = ''
            rustc ${features} ${toString flags} --allow dead_code \
                  --crate-type=lib --crate-name=core --target=${target} \
                  --edition=2021 ./lib/rustlib/src/rust/library/core/src/lib.rs
          '';

          installPhase = ''
            install -Dm644 -t $out/lib/rustlib/${target}/lib libcore.rlib 
          '';

          dontStrip = true;
        };

      rustc' = combine [
        rustc-unwrapped
        core
      ];

      compiler-builtins =
        let
          features = featuresToCfg [
            "compiler-builtins"
            "core"
            "default"
            "mem"
            "rustc-dep-of-std"
            "unstable"
          ];
        in
        stdenv.mkDerivation {
          pname = "compiler_builtins-${target}";
          version = "0.1.140";

          src = fetchFromGitHub {
            owner = "rust-lang";
            repo = "compiler-builtins";
            tag = "compiler_builtins-v0.1.140";
            sha256 = "b0EPGAXPEg2kWVCqf2Io8/mXKt9+h+hP/0Tz9HjWWUY=";
          };

          nativeBuildInputs = [ rustc' ];

          buildPhase = ''
            rustc ${features} ${toString flags} --allow unstable_name_collisions \
                  --crate-type=lib --crate-name=compiler_builtins --target=${target} \
                  --edition=2021 src/lib.rs
          '';

          installPhase = ''
            install -Dm644 -t $out/lib/rustlib/${target}/lib  libcompiler_builtins.rlib
          '';

          dontStrip = true;
        };
    in
    (combine [
      rustc'
      compiler-builtins
    ]).overrideAttrs
      (ol: {
        passthru = (ol.passthru or { }) // {
          inherit target;
        };
      });
in
{
  aarch64-apple-ios = toolchain "aarch64-apple-ios";
  aarch64-apple-ios-sim = toolchain "aarch64-apple-ios-sim";
  aarch64-apple-darwin = toolchain "aarch64-apple-darwin";
  x86_64-unknown-linux-gnu = toolchain "x86_64-unknown-linux-gnu";

  toolchainFor = toolchain;
}
