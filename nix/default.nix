{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      inputs',
      ...
    }:
    {
      _module.args.pkgs' = pkgs.callPackage ./pkgs {
        inherit (inputs) buck2-src;
        inherit (inputs'.fenix.packages) fromToolchainFile;
      };
    };
}
