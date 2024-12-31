{
  stdenv,
  toolchain,
  flags ? [
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
stdenv.mkDerivation {
  pname = "dev71-prelude-${toolchain.target}";
  version = "0.1.0";

  src = ../prelude;

  nativeBuildInputs = [ toolchain ];

  buildPhase = ''
    rustc ${toString flags} --crate-name=prelude --crate-type=staticlib --target=${toolchain.target} \
          --edition=2024 prelude.rs
  '';

  installPhase = ''
    mkdir -p $out/{lib,include}

    cp prelude.h module.modulemap $out/include
    cp libprelude.a $out/lib
  '';

  dontStrip = true;
}
