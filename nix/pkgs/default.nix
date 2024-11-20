{
  lib,
  pkgs,
  buck2-src,
  fromToolchainFile,
  makeRustPlatform,
}: let
  callBuckPackage = lib.callPackageWith (pkgs
    // {
      inherit buck2-src;

      cargoLock = {
        lockFile = ./support/Buck2.lock;
        outputHashes = {
          "hyper-proxy-0.10.1" = "qxOJntADYGuBr9jnzWJjiC7ApnkmF2R+OdXBGL3jIw8=";
          "perf-event-0.4.8" = "4OSGmbrL5y1g+wdA+W9DrhWlHQGeVCsMLz87pJNckvw=";
        };
      };

      rustPlatform = let
        toolchain = fromToolchainFile {
          file = "${buck2-src}/rust-toolchain";
          sha256 = "oW7iyYzGcgW5TjRA2HLhYVW2WNTNadIe4SX7IWsrs3g=";
        };
      in
        makeRustPlatform {
          rustc = toolchain;
          cargo = toolchain;
        };
    });
in {
  buck2 = callBuckPackage ./buck2.nix {};
  rust-project = callBuckPackage ./rust-project.nix {};
}
