import ProjectDescription

let project = Project(
    name: "Dev71",
    targets: [
        .target(
            name: "Dev71",
            destinations: .iOS,
            product: .app,
            bundleId: "ae.dev71.Dev71",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ]
                ]
            ),
            sources: ["src/main.swift"],
            dependencies: [.xcframework(path: "zig-out/Prelude.xcframework")],
            mergedBinaryType: .automatic
        )
    ],
    schemes: [
        .scheme(
            name: "Dev71",
            buildAction: .buildAction(
                targets: [.target("Dev71")],
                preActions: {
                    guard case let .string(zig) = Environment.zig else { return [] }
                    return [
                        .executionAction(
                            scriptText: "(cd $SRCROOT; \(zig) build ios)", target: "Dev71")
                    ]
                }()
            )
        )
    ]
)
