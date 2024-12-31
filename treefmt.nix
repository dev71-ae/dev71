{ inputs, ... }:
{
  perSystem =
    { inputs', ... }:
    {
      treefmt.config = {
        projectRootFile = "flake.nix";

        flakeCheck = true;
        flakeFormatter = true;

        # .nix
        programs.nixfmt.enable = true;

        # .h
        programs.clang-format.enable = true;

        # .sh
        programs.shellcheck.enable = true;

        # .rs
        programs.rustfmt = {
          enable = true;
          package = inputs'.fenix.packages.complete.rustfmt;
        };

        settings.global.excludes = [
          "*.{md,swift,envrc,kt,plist}"
        ];
      };
    };

  imports = [ inputs.treefmt.flakeModule ];
}
