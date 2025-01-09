{ pkgs }:
let
  inherit (pkgs) lib stdenv;
in
{
  packages =
    builtins.attrValues {
      inherit (pkgs) zig zls;
      inherit (pkgs.llvmPackages) clang clang-tools;
    }
    ++ lib.optionals stdenv.isDarwin [ pkgs.tuist ];
}
