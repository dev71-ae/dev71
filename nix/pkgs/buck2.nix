{
  lib,
  stdenv,
  buck2-src,
  cargoLock,
  rustPlatform,
  llvmPackages,
  pkg-config,
  mold-wrapped,
  libiconv,
  darwin,
  openssl,
  sqlite,
  protobuf,
  installShellFiles,
}:
rustPlatform.buildRustPackage {
  pname = "buck2";
  version = builtins.toString buck2-src.lastModified;
  src = buck2-src;

  inherit cargoLock;

  postPatch = ''
    ln -s ${./support/Buck2.lock} Cargo.lock
  '';

  nativeBuildInputs =
    [protobuf pkg-config installShellFiles llvmPackages.lld llvmPackages.clang]
    ++ lib.optionals stdenv.isLinux [mold-wrapped];

  buildInputs =
    [openssl sqlite]
    ++ lib.optionals stdenv.isDarwin (builtins.attrValues {
      inherit libiconv;
      inherit (darwin.apple_sdk.frameworks) CoreFoundation CoreServices IOKit Security;
    });

  strictDeps = true;

  # FIXME: app/buck2_build_api tests fail with "Error loading system root certificates native frameworks"
  # Disable for now
  doCheck = false;

  BUCK2_BUILD_PROTOC = lib.getExe protobuf;
  BUCK2_BUILD_PROTOC_INCLUDE = "${protobuf}/include";

  CARGO_BUILD_RUSTFLAGS =
    if stdenv.isLinux
    then "-C linker=clang -C link-arg=-fuse-ld=mold -Wl,--compress-debug-sections=zstd"
    else if stdenv.isDarwin
    then "-C linker=-fuse-ld=ld -ld_new"
    else "";

  postInstall = ''
    installShellCompletion --cmd buck2 \
      --bash <( $out/bin/buck2 completion bash ) \
      --fish <( $out/bin/buck2 completion fish ) \
      --zsh <( $out/bin/buck2 completion zsh )
  '';
}
