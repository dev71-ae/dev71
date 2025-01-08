{
  lib,
  stdenv,
  mkNakedShell,
  zig,
  zls,
  llvmPackages,
  tuist,
}:
mkNakedShell {
  name = "dev71-shell";
  packages = [
    zig
    zls
    llvmPackages.clang
    llvmPackages.clang-tools
  ] ++ lib.optionals stdenv.isDarwin [ tuist ];
}
