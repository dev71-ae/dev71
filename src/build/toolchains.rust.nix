{
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
      core = stdenv.mkDerivation {
        pname = "core-${target}";
        version = rust-src.version;

        src = rust-src;

        nativeBuildInputs = [ rustc-unwrapped ];

        buildPhase = ''
          rustc --cfg='feature="optimize_for_size"' --cfg='feature="panic_immediate_abort"' \
                -Cpanic=abort -Copt-level=2 -Zforce-unstable-if-unmarked --allow dead_code \
                --crate-type=lib --crate-name=core --target=${target} --edition=2021 \
                ./lib/rustlib/src/rust/library/core/src/lib.rs
        '';

        installPhase = ''
          mkdir -p $out/lib/rustlib/${target}/lib
          cp -r libcore.rlib $out/lib/rustlib/${target}/lib
        '';

        dontStrip = true;
      };

      rustc' = combine [
        rustc-unwrapped
        core
      ];

      compiler-builtins = stdenv.mkDerivation {
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
          rustc --cfg 'feature="compiler-builtins"' --cfg 'feature="core"' --cfg 'feature="default"' \
                --cfg 'feature="mem"' --cfg 'feature="rustc-dep-of-std"' --cfg 'feature="unstable"' \
                -Cpanic=abort -Copt-level=2 -Zforce-unstable-if-unmarked --allow unstable_name_collisions \
                --crate-type=lib --crate-name=compiler_builtins --target=${target} --edition=2021 \
                src/lib.rs
        '';

        installPhase = ''
          mkdir -p $out/lib/rustlib/${target}/lib
          cp -r libcompiler_builtins.rlib $out/lib/rustlib/${target}/lib
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
