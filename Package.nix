{
  prelude =
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
        root = ./.;
        fileset = lib.fileset.unions [
          ./build.zig
          ./src/prelude
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
    };

  # TODO:
  ios =
    {
      lib,
      stdenvNoCC,
      xcode,
      tuist,
      simulator ? false,
      sdk ? if simulator then xcode.sdk.iphonesimulator else xcode.sdk.iphoneos,
    }:
    stdenvNoCC.mkDerivation {
      pname = "Dev71";
      version = "0.1.0" + (lib.optionalString simulator "-sim");

      src = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions [
          ./src/Main.swift
        ];
      };

      nativeBuildInputs = [
        #xcode
        tuist
      ];

      #SDKROOT = sdk;

      buildPhase = ''
        tuist build # pain
      '';

      installPhase = ''
        exit 0
        mkdir -p $out/Dev71
      '';

      passthru.id = "ae.dev71.Dev71";
    };
}
