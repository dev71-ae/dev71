root := justfile_directory()

darwin := root / "darwin"
target := root / "target"
include := root / "include"

arch := arch()
simulator-target := if arch == "aarch64" { "aarch64-apple-ios-sim" } else { "x86_64-apple-ios" } 

[private]
default: 
    @just --list --unsorted

help: default

[group("lib")]
[doc("Generates C header file using cbindgen")]
bindgen:
    cbindgen --config {{ root / "cbindgen.toml" }} --crate dev71 --output {{ include / "dev71.h" }}

[macos]
[group("lib")]
[doc("Generates static libraries for iOS architectures")]
release-ios: 
    cargo build --release \
                --target aarch64-apple-ios \
                --target {{ simulator-target }}   

[macos]
[group("darwin")]
[doc("Generates xcframework for all architectures")]
[confirm("This will overwrite darwin/xcframeworks/Core71.xcframework, are you sure? (y[es]/n[o]):")]
xcframework: release-ios
    rm -rf {{ darwin / "xcframeworks/Core71.xcframework" }}
    xcodebuild -create-xcframework \
               -library {{ target / "aarch64-apple-ios/release/libdev71.a" }} \
               -headers {{ include }} \
               -library {{ target / simulator-target / "release/libdev71.a" }} \
               -headers {{ include }} \
               -output {{ darwin / "xcframeworks/Core71.xcframework" }}
