{
  lib,
  stdenv,
  stdenvAdapters,
  fetchFromGitHub,
  fromToolchainFile,
  makeRustPlatform,
  pkg-config,
  libiconv,
  darwin,
  openssl,
  sqlite,
  protobuf,
  installShellFiles,
}:
let
  # Nov 26, 2024 
  version = "2caeefc19c0bffd7814ea2a7836f4687df4552eb";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = "buck2";
    rev = version;
    sha256 = "tEwuqUXDTfqaEb9t6F64Kjp9htR+vdzWWeGJDFovMNQ=";
  };

  rustPlatform =
    let
      toolchain = fromToolchainFile {
        file = "${src}/rust-toolchain";
        sha256 = "oW7iyYzGcgW5TjRA2HLhYVW2WNTNadIe4SX7IWsrs3g=";
      };
    in
    makeRustPlatform {
      rustc = toolchain;
      cargo = toolchain;
      stdenv = if stdenv.isLinux then stdenvAdapters.useMoldLinker stdenv else stdenv;
    };
in
rustPlatform.buildRustPackage {
  pname = "buck2";

  inherit version src;

  cargoLock = {
    lockFile = ./Cargo.lock;
    # or allowBuiltinFetchGit = true; works. Given non-nixpkgs context.
    outputHashes = {
      "hyper-proxy-0.10.1" = "qxOJntADYGuBr9jnzWJjiC7ApnkmF2R+OdXBGL3jIw8=";
      "perf-event-0.4.8" = "4OSGmbrL5y1g+wdA+W9DrhWlHQGeVCsMLz87pJNckvw=";
    };
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    protobuf
    pkg-config
    installShellFiles
  ];

  buildInputs =
    [
      openssl
      sqlite
    ]
    ++ lib.optionals stdenv.isDarwin (
      builtins.attrValues {
        inherit libiconv;
        inherit (darwin.apple_sdk.frameworks)
          CoreFoundation
          CoreServices
          IOKit
          Security
          ;
      }
    );

  strictDeps = true;
  cargoBuildFlags = [ "--bin buck2" ];

  BUCK2_BUILD_PROTOC = lib.getExe protobuf;
  BUCK2_BUILD_PROTOC_INCLUDE = "${protobuf}/include";

  postInstall = ''
    installShellCompletion --cmd buck2 \
      --bash <( $out/bin/buck2 completion bash ) \
      --fish <( $out/bin/buck2 completion fish ) \
      --zsh <( $out/bin/buck2 completion zsh )
  '';

  doCheck = false; # Fails in some cases, and is too slow.
}
