{
  description = "dev71-ae/core: Shared logic between the native apps.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [{perSystem = {lib, ...}: {_module.args.l = lib // builtins;};}];
      perSystem = {
        l,
        pkgs,
        ...
      }: {
        devShells.default = pkgs.mkShell {
          packages = l.attrValues {
            inherit (pkgs) zig;
          };
        };
      };

      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
    };
}
