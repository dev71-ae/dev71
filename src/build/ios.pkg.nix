{
  lib,
  stdenvNoCC,
  substitute,
  target,
  prelude,
  profile, # TODO: Figure out how to emulate `swift build -c release`
  xcode,
}:
let
  fs = lib.fileset;

  xctoolchain = "${xcode}/Contents/Developer/Toolchains/XcodeDefault.xctoolchain";
  sdk = "${xcode}/Contents/Developer/Platforms/${platform}.platform/Developer/SDKs/${platform}.sdk";

  platform = if isSimulator then "iPhoneSimulator" else "iPhoneOS";
  isSimulator = lib.hasSuffix "simulator" target;

  id = "ae.dev71.Dev71";
  bname = "Dev71";
  executable = "Dev71";
  version = "0.1.0";

  plist = substitute {
    src = ../../data/Info.plist;
    substitutions = [
      "--replace"
      "\${EXECUTABLE_NAME}"
      executable
      "--replace"
      "\${PRODUCT_BUNDLE_IDENTIFIER}"
      id
      "--replace"
      "\${PRODUCT_NAME}"
      "Dev71"
      "--replace"
      "\${PRODUCT_VERSION}"
      version
      "--replace"
      "\${PRODUCT_BUNDLE_VERSION}"
      version
    ];
  };
in
stdenvNoCC.mkDerivation {
  pname = "dev71-ios-" + profile + (if isSimulator then "-sim" else "");
  inherit version;

  src = fs.toSource {
    root = ../..;
    fileset = fs.unions [
      ../Main.swift
    ];
  };

  buildPhase = ''
    ${xctoolchain}/usr/bin/swiftc ./src/Main.swift -target ${target} -I${prelude}/include -L${prelude}/lib -lprelude -sdk ${sdk} -o ${executable}
  '';

  installPhase = ''
    mkdir -p $out/Applications/Dev71.app

    cp ${plist} $out/Applications/${bname}.app/Info.plist 
    cp ${executable} $out/Applications/${bname}.app
  '';

  passthru = {
    inherit
      sdk
      target
      prelude
      id
      bname
      executable
      ;
  };
}
