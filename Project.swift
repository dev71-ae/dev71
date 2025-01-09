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
                        "prelude",
                        "-Dtarget=aarch64-ios$LLVM_TARGET_TRIPLE_SUFFIX",
                        #"-Doptimize=$([ "$CONFIGURATION" == "Release" ] && echo "ReleaseSafe" || echo "Debug")"#,
                        "--prefix-lib-dir",
                        #""$BUILT_PRODUCTS_DIR/$EXECUTABLE_FOLDER_PATH""#,
                    ],
                    name: "Run zig build",
                    inputPaths: ["src/prelude/**/*.zig"],
                    outputPaths: ["$(BUILT_PRODUCTS_DIR)/$(EXECUTABLE_PATH)"],
                    basedOnDependencyAnalysis: true
                )
            ],
            // For good measure, preventing the generation of any executable.
            settings: .settings(base: ["VERSIONING_SYSTEM": "None"])
        ),
    ]
)
