{
  pkgs,
  lib ? pkgs.lib,
  stdenv ? pkgs.stdenv,
  zig ? pkgs.zig,
  zls ? pkgs.zls,
  llvmPackages ? pkgs.llvmPackages_19,
  tuist ? pkgs.tuist,
}:
{
  packages = [
    zls
    llvmPackages.clang
    llvmPackages.clang-tools
  ];

  commands =
    [
      {
        package = zig;
        category = "[core]";
        help = "Zig is used to build the core libraries. TIP: Remember to specify a `-Dtarget` to `zig build` e.g aarch64-ios(-simulator) for cross.";
      }
    ]
    ++ lib.optionals stdenv.isDarwin [
      {
        name = "ios";
        category = "[darwin development]";
        help = "Calls `tuist generate` to get you into Xcode with the project setup. NOTE: Xcode will automagically run `zig build` when the zig files change.";
        # Zig build is just for good measure
        command = "zig build -Dtarget=aarch64-ios-simulator && tuist generate";
      }
      {
        package = tuist;
        category = "[darwin development]";
        help = "Tuist is the tool we use to generate the Xcode project files. TIP: Run `tuist edit` to modify the Project.swift manifest.";
      }
    ];
}
