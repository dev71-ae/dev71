import Foundation
import ProjectDescription

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
                .xcframework(path: resolveCore71XCFramework(), status: .required)
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

func resolveCore71XCFramework() -> Path {
    let frameworkName = "Core71.xcframework"
    let frameworkPath = "xcframeworks/\(frameworkName)"

    var isDirectory: ObjCBool = true
    if !FileManager.default.fileExists(atPath: frameworkPath, isDirectory: &isDirectory) {
        print(
            """
            \n\u{001b}[33mPlease build \(frameworkName) first by running `just xcframework`.
            Those using nix with direnv, cd back to the main project directory and run the command.
            """)
    }

    return .path(frameworkPath)
}
