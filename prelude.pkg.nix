{
  stdenv,
  fetchFromGitHub,
  fenix,
  rustc-target,
  rustc-flags ? [
    "-Ccodegen-units=1"
    "-Cpanic=abort"
    "-Copt-level=z"
    "-Clto=fat"
    "-Cstrip=symbols"
    "-Cdebuginfo=0"
    "-Cdebug-assertions=false"
    "-Coverflow-checks=false"
    "-Zlocation-detail=none"
    "-Zfmt-debug=none"
  ],
}:
let
  rustc = fenix.minimal.rustc-unwrapped;
  inherit (fenix.complete) rust-src;

  core = stdenv.mkDerivation {
    pname = "core-${rustc-target}";
    version = rust-src.version;

    src = rust-src;

    nativeBuildInputs = [ rustc ];

    buildPhase = ''
      rustc --cfg='feature="optimize_for_size"' --cfg='feature="panic_immediate_abort"' \
            -Cpanic=abort -Copt-level=2 -Zforce-unstable-if-unmarked --allow dead_code \
            --crate-type=lib --crate-name=core --target=${rustc-target} --edition=2021 \
            ./lib/rustlib/src/rust/library/core/src/lib.rs
    '';

    installPhase = ''
      mkdir -p $out/lib/rustlib/${rustc-target}/lib
      cp -r libcore.rlib $out/lib/rustlib/${rustc-target}/lib
    '';

    dontStrip = true;
  };

  rustc' = fenix.combine [
    rustc
    core
  ];

  compiler-builtins = stdenv.mkDerivation {
    pname = "compiler_builtins-${rustc-target}";
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
            --crate-type=lib --crate-name=compiler_builtins --target=${rustc-target} --edition=2021 \
            src/lib.rs
    '';

    installPhase = ''
      mkdir -p $out/lib/rustlib/${rustc-target}/lib
      cp -r libcompiler_builtins.rlib $out/lib/rustlib/${rustc-target}/lib
    '';

    dontStrip = true;
  };

  toolchain = fenix.combine [
    rustc'
    compiler-builtins
  ];
in
stdenv.mkDerivation {
  pname = "dev71-prelude-${rustc-target}";
  version = "0.1.0";

  src = ./src/prelude;

  nativeBuildInputs = [ toolchain ];

  buildPhase = ''
    rustc ${toString rustc-flags} --crate-name=prelude --crate-type=staticlib --target=${rustc-target} \
          --edition=2024 prelude.rs
  '';

  installPhase = ''
    mkdir -p $out/{lib,include}
    ls -la

    cp prelude.h $out/include
    cp libprelude.a $out/lib
  '';
}
