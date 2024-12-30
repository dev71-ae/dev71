{
  stdenv,
  rustc,
  rust-src,
  fenix,
  fetchFromGitHub,
  ...
}:
target:
let
  core = stdenv.mkDerivation {
    pname = "rust-core";
    version = rust-src.version;

    src = rust-src;

    nativeBuildInputs = [ rustc ];

    buildPhase = ''
      rustc --cfg='feature="optimize_for_size"' \
            --cfg='feature="panic_immediate_abort"' \
            -Cpanic=abort \
            -Copt-level=2 \
            -Zforce-unstable-if-unmarked \
            --crate-name=core \
            --crate-type=lib \
            --edition=2021 \
            --target=${target} \
            ./lib/rustlib/src/rust/library/core/src/lib.rs
    '';

    installPhase = ''
      mkdir -p $out/lib/rustlib/${target}/lib
      cp -r libcore.rlib $out/lib/rustlib/${target}/lib
    '';

    dontStrip = true;
  };

  rustc' = fenix.combine [
    rustc
    core
  ];

  compiler-builtins = stdenv.mkDerivation {
    pname = "compiler_builtins";
    version = "0.1.140";

    src = fetchFromGitHub {
      owner = "rust-lang";
      repo = "compiler-builtins";
      tag = "compiler_builtins-v0.1.140";
      sha256 = "b0EPGAXPEg2kWVCqf2Io8/mXKt9+h+hP/0Tz9HjWWUY=";
    };

    nativeBuildInputs = [ rustc' ];

    buildPhase = ''
      rustc --cfg 'feature="compiler-builtins"' \
            --cfg 'feature="core"' \
            --cfg 'feature="default"' \
            --cfg 'feature="mem"' \
            --cfg 'feature="rustc-dep-of-std"' \
            --cfg 'feature="unstable"' \
            -Cpanic=abort \
            -Copt-level=2 \
            -Zforce-unstable-if-unmarked \
            --crate-type=lib \
            --crate-name=compiler_builtins \
            --allow unstable_name_collisions \
            --edition=2021 \
            --target=${target} \
            src/lib.rs
    '';

    installPhase = ''
      mkdir -p $out/lib/rustlib/${target}/lib
      cp -r libcompiler_builtins.rlib $out/lib/rustlib/${target}/lib
    '';

    dontStrip = true;
  };
in
fenix.combine [
  core
  compiler-builtins
]
