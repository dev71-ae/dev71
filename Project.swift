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
			dependencies: []
		)
	]
)
