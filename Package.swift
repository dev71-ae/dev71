// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Dev71",
    platforms: [.iOS(.v15)],
    targets: [
        .executableTarget(name: "Dev71", sources: ["Main.swift"])
    ]
)
