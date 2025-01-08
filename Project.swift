import ProjectDescription

let project = Project(
    name: "Dev71",
    targets: [
        .target(
            name: "Dev71",
            destinations: .iOS,
            product: .app,
            bundleId: "ae.dev71.Dev71",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ]
                ]
            ),
            sources: ["src/main.swift"],
            dependencies: [.target(name: "Prelude")],
            mergedBinaryType: .automatic
        ),
        .target(
            name: "Prelude",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "ae.dev71.Libs.Prelude",
            deploymentTargets: .iOS("12.0"),
            headers: .headers(public: ["src/prelude/*.h"]),
            scripts: [
                .pre(
                    tool: "zig",
                    arguments: [
                        "build",
                        "-Dtarget=aarch64-ios$LLVM_TARGET_TRIPLE_SUFFIX",
                    ],
                    name: "Run zig build",
                    inputPaths: ["src/prelude/**/*.zig"],
                    outputPaths: ["zig-out/lib/libprelude.a"],
                    basedOnDependencyAnalysis: true
                )
            ],
            dependencies: [
                .library(
                    path: "zig-out/lib/libprelude.a",
                    publicHeaders: "", swiftModuleMap: .none,
                    condition: .none)
            ]
        ),
    ]
)
