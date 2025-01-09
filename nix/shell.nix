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
        package = tuist;
        category = "[darwin development]";
        help = "Tuist is the tool we use to generate the Xcode project files. TIP: Pass `generate` to get into xcode. Note that Xcode automagically will build the zig files on change.";
      }
    ];
}
