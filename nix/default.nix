let
  inherit (import ./npins) atom;
  importAtom = import "${atom}/atom-nix/core/importAtom.nix";
in
{
  dev =
    {
      features ? [ ],
    }:
    importAtom { inherit features; } (./. + "/dev@.toml");
}
