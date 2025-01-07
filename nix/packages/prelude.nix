{
  lib,
  stdenv,
  zig,
  target ? "native",
  optimize ? "ReleaseSmall",
}:
stdenv.mkDerivation {
  pname = "prelude";
  version = "0.1.0-${target}";

  src = lib.fileset.toSource {
    root = ../..;
    fileset = lib.fileset.unions [
      ../../build.zig
      ../../src/prelude
    ];
  };

  nativeBuildInputs = [
    zig
    zig.hook
  ];

  zigBuildFlags = [
    "-Dtarget=${target}"
    "-Doptimize=${optimize}"
  ];
}
