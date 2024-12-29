#!/bin/bash

set -e

# Step 1: Build Dependencies Using Cargo (to download dependencies)
download_dependencies() {
	echo "Downloading and building dependencies using cargo..."
	cargo fetch
}

RUST_RELEASE_FLAGS=(
	"-Ccodegen-units=1"
	"-Cpanic=abort"
	"-Copt-level=s"
	"-Clto=fat"
	"-Cstrip=symbols"
	"-Cdebuginfo=0"
	"-Cdebug-assertions=false"
	"-Coverflow-checks=false"
	"-Zlocation-detail=none"
	"-Zfmt-debug=none"
	"-Zstaticlib-allow-rdylib-deps"
	"-Zstaticlib-prefer-dynamic"
)

# Step 2: Build the Project Using rustc to Generate a Static Library (.a)
build_project() {
	echo "Building project with rustc to create a static library..."
	cargo rustc --release -- "${RUST_RELEASE_FLAGS[@]}" --print native-static-libs

	# NOTE: Please set the following environment variables before running the build script
	# SDKROOT environment variable - path to iPhoneOS.sdk or iPhoneSimulator.sdk
	# IPHONEOS_DEPLOYMENT_TARGET - The minimum supported version is iOS 10.0
	# cargo rustc --release --target aarch64-apple-ios -- "${RUST_RELEASE_FLAGS[@]}" --print native-static-libs
}

main() {
	download_dependencies
	build_project
	echo "Build complete."
}

main
