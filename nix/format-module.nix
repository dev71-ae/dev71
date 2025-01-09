{ inputs, ... }:
{
  perSystem.treefmt.config = {
    projectRootFile = "flake.nix";

    flakeCheck = true;
    flakeFormatter = true;

    # .nix
    programs.nixfmt.enable = true;

    # .c, .h
    programs.clang-format.enable = true;

    # .zig
    programs.zig.enable = true;

    settings.global.excludes = [
      "*.{md,swift,envrc}"
    ];
  };

  imports = [ inputs.treefmt.flakeModule ];
}
