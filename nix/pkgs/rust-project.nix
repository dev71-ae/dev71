{
  buck2-src,
  cargoLock,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "rust-project";
  version = builtins.toString buck2-src.lastModified;

  src = buck2-src;
  buildAndTestSubdir = "integrations/rust-project";

  inherit cargoLock;

  postPatch = ''
    ln -s ${./support/Buck2.lock} Cargo.lock
  '';

  strictDeps = true;
}
