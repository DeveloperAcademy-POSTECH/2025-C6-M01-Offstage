import ProjectDescription

let formatScript: TargetScript = .pre(
    path: .relativeToRoot("Scripts/swiftformat.sh"),
    name: "SwiftFormat (mise, --lint)",
    basedOnDependencyAnalysis: false
)

let lintScript: TargetScript = .pre(
    path: .relativeToRoot("Scripts/swiftlint.sh"),
    name: "SwiftLint (mise)",
    basedOnDependencyAnalysis: false
)

let project = Project(
    name: "OffStageApp",
    targets: [
        .target(
            name: "OffStageApp",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.OffStageApp",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            buildableFolders: [
                "OffStageApp/Sources",
                "OffStageApp/Resources",
            ],
            scripts: [formatScript, lintScript],
            dependencies: []
        ),
        .target(
            name: "OffStageAppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.OffStageAppTests",
            infoPlist: .default,
            buildableFolders: [
                "OffStageApp/Tests",
            ],
            dependencies: [.target(name: "OffStageApp")]
        ),
    ]
)
