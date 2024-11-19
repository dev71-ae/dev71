root := justfile_directory()

[private]
default: 
    @just --list --unsorted

[group("darwin")]
[doc("Generates xcframework for all static libs")]
xcframework: release-ios
    xcodebuild -create-xcframework -library target/aarch64-apple-ios/release/libdev71.a -headers include -library target/aarch64-apple-ios-sim/release/libdev71.a -headers include -output {{root}}/darwin/xcframeworks/Core71.xcframework

[group("lib")]
[doc("Generates static libraries for all static libs")]
release-ios:
    cargo build --release --target aarch64-apple-ios --target aarch64-apple-ios-sim --target x86_64-apple-ios

[group("lib")]
bindgen:
    cbindgen --config {{ root }}/cbindgen.toml --crate dev71 --output include/dev71.h
