{ withSystem, ... }:
{
  flake.apps.aarch64-darwin = withSystem "aarch64-darwin" (
    { pkgs, ... }:
    {
      xcgen = {
        type = "app";
        program = "${pkgs.callPackage ./apps/xcgen.nix { }}/bin/xcgen";
      };
    }
  );
}
