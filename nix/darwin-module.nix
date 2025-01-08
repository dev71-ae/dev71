{ withSystem, ... }:
{
  flake = withSystem "aarch64-darwin" ({ ... }: { });
}
