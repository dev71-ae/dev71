{
  lib,
  stdenv,
  mkNakedShell,
  zig,
  zls,
  tuist,
}:
mkNakedShell {
  name = "dev71-shell";
  packages = [
    zig
    zls
  ] ++ lib.optionals stdenv.isDarwin [ tuist ];
}
