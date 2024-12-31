{
  lib,
  stdenvNoCC,
  swiftc-target,
  prelude,
  # 16.2: nix store add --hash-algo sha256 /Applications/Xcode.app
  xcode ? builtins.fetchClosure {
    fromStore = "https://cache.nixos.org";
    fromPath = /nix/store/npfc6494dw4yz0iiqyi4sfnrwkyc9cyf-Xcode.app;
  },
}:
let
  fs = lib.fileset;

  xctoolchain = "${xcode}/Contents/Developer/Toolchains/XcodeDefault.xctoolchain";
  platform = if isSimulator then "iPhoneSimulator" else "iPhoneOS";

  isSimulator = lib.hasSuffix "simulator" swiftc-target;

  sdk = "${xcode}/Contents/Developer/Platforms/${platform}.platform/Developer/SDKs/${platform}.sdk";
in
stdenvNoCC.mkDerivation {
  pname = "dev71-ios${if isSimulator then "-sim" else ""}";
  version = "0.1.0";

  src = fs.toSource {
    root = ../..;
    fileset = fs.unions [
      ../../data/Info.plist
      ../Main.swift
    ];
  };

  buildPhase = ''
    ${xctoolchain}/usr/bin/swiftc ./src/Main.swift -target ${swiftc-target} -I${prelude}/include -L${prelude}/lib -lprelude -sdk ${sdk} -o Dev71
  '';

  installPhase = ''
    mkdir -p $out/Applications/Dev71.app

    cp ./data/Info.plist $out/Applications/Dev71.app 
    cp Dev71 $out/Applications/Dev71.app
  '';

  passthru = {
    inherit sdk prelude;
    target = swiftc-target;
  };
}
