{ inputs, ... }:
{
  perSystem.treefmt.config = {
    projectRootFile = "flake.nix";
    flakeFormatter = true;

    programs.nixfmt.enable = true;
    programs.rustfmt.enable = true;
    programs.buildifier.enable = true;
    programs.biome.enable = true;
    programs.taplo.enable = true;

    settings.global.excludes = [
      ".buckroot"
      ".buckconfig"
      "*/.buckconfig"
      ".gitattributes"
      "build/mode/{debug,release}"
      "dev/dotslash/*"
      "*.{md,envrc,swift}"
    ];

    settings.formatter.buildifier.includes = [
      "BUCK"
      "*/BUCK"
      "PACKAGE"
      "*/PACKAGE"
    ];
  };

  imports = [ inputs.treefmt.flakeModule ];
}
