import ProjectDescription

let buildArch = "{}"

let project = Project(
    name: "Dev71",
    targets: [
        .target(
            name: "Dev71",
            destinations: .iOS,
            product: .app,
            bundleId: "ae.dev71.App",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ]
                ]
            ),
            sources: ["Dev71/Sources/**"],
            resources: ["Dev71/Resources/**"],
            dependencies: [
                .xcframework(path: .path("xcframeworks/Core71.xcframework"), status: .required)
            ]
        ),
        .target(
            name: "Dev71Tests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "ae.dev71.AppTests",
            infoPlist: .default,
            sources: ["Dev71/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Dev71")]
        ),
    ]
)
