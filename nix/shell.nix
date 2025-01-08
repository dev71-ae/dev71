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

  shellHook = lib.optionalString stdenv.isDarwin "echo -e '\\033[1;34mNOTE(iOS): Make sure to run `zig build` before `tuist generate`\\033[0m'";
}
