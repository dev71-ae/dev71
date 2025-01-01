{
  lib,
  substitute,
  stdenvNoCC,
  prelude,
  xcode,
  target,
  isSimulator ? lib.hasSuffix "simulator" target,
}:
let
  fs = lib.fileset;
  xctoolchain = "${xcode}/Contents/Developer/Toolchains/XcodeDefault.xctoolchain";

  platform = if isSimulator then "iPhoneSimulator" else "iPhoneOS";
  sdk = "${xcode}/Contents/Developer/Platforms/${platform}.platform/Developer/SDKs/${platform}.sdk";

  data = {
    EXECUTABLE_NAME = "Dev71";
    PRODUCT_BUNDLE_IDENTIFIER = "ae.dev71.Dev71";
    PRODUCT_NAME = "Dev71";
    PRODUCT_VERSION = "0.1.0";
    PRODUCT_BUNDLE_VERSION = "0.1.0";
  };

  plist = substitute {
    src = ../../data/Info.plist;
    substitutions =
      with lib;
      flatten (
        attrValues (
          mapAttrs (name: value: [
            "--replace"
            "\${${name}}"
            value
          ]) data
        )
      );
  };
in
stdenvNoCC.mkDerivation {
  pname = data.PRODUCT_NAME + ".app";
  version = data.PRODUCT_VERSION + (if isSimulator then "-sim" else "");

  src = fs.toSource {
    root = ../..;
    fileset = fs.unions [
      ../Main.swift
    ];
  };

  buildPhase = ''
    ${xctoolchain}/usr/bin/swiftc ./src/Main.swift -target ${target} -sdk ${sdk} \
    -I${prelude}/include -L${prelude}/lib -lprelude -o ${data.EXECUTABLE_NAME}
  '';

  installPhase = ''
    install -Dm644 ${plist} $out/Applications/${data.PRODUCT_NAME}.app/Info.plist
    install -Dm755 -t $out/Applications/${data.PRODUCT_NAME}.app ./${data.EXECUTABLE_NAME}
  '';

  passthru = {
    inherit
      sdk
      target
      data
      ;
  };
}
