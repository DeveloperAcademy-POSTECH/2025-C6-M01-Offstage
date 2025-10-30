import ProjectDescription

let organizationName = "2025C6.OffStage"

let baseInfoPlist: [String: Plist.Value] = [
    "CFBundleDisplayName": "$(APP_DISPLAY_NAME)",
    "UILaunchScreen": [
        "UIColorName": "",
        "UIImageName": "",
    ],
    "CFBundleShortVersionString": "1.0",
    "CFBundleVersion": "1",
    "ARRIVAL_SERVICE_KEY": "$(ARRIVAL_SERVICE_KEY)",
    "LOCATION_SERVICE_KEY": "$(LOCATION_SERVICE_KEY)",
    "STOP_SERVICE_KEY": "$(STOP_SERVICE_KEY)",
    "ROUTE_SERVICE_KEY": "$(ROUTE_SERVICE_KEY)",
    "NSLocationWhenInUseUsageDescription": "현재 위치를 기반으로 주변 정류장 정보를 제공하기 위해 위치 정보가 필요합니다.",
    "NSCameraUsageDescription": "버스 인식을 위해 카메라 접근이 필요합니다.",
    "ITSAppUsesNonExemptEncryption": .boolean(false),
    "UIDesignRequiresCompatibility": .boolean(true),
    "UIUserInterfaceStyle": "Dark",
]

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

let busAPI = Target.target(
    name: "BusAPI",
    destinations: [.iPhone],
    product: .framework,
    bundleId: "\(organizationName).BusAPI",
    infoPlist: .extendingDefault(with: baseInfoPlist),
    sources: ["Modules/BusAPI/Sources/**"],
    dependencies: [
        .external(name: "Moya"),
        .external(name: "Logging"),
    ]
)

let busAPITests = Target.target(
    name: "BusAPITests",
    destinations: [.iPhone],
    product: .unitTests,
    bundleId: "\(organizationName).BusAPITests",
    infoPlist: .default,
    sources: ["Modules/BusAPITests/Sources/**"],
    dependencies: [
        .target(name: "BusAPI"),
        .target(name: "OffStageApp"),
    ]
)

let configurations: [Configuration] = [
    .debug(name: "Debug-Dev", xcconfig: .relativeToRoot("Config/Dev.xcconfig")),
    .release(name: "Release-Dev", xcconfig: .relativeToRoot("Config/Dev.xcconfig")),
    .debug(name: "Debug-Prod", xcconfig: .relativeToRoot("Config/Prod.xcconfig")),
    .release(name: "Release-Prod", xcconfig: .relativeToRoot("Config/Prod.xcconfig")),
]

let app = Target.target(
    name: "OffStageApp",
    destinations: [.iPhone],
    product: .app,
    bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
    infoPlist: .extendingDefault(with: baseInfoPlist),
    sources: ["OffStageApp/Sources/**"],
    resources: ["OffStageApp/Resources/**", "OffStageApp/Resources/*.mlmodel"],
    scripts: [formatScript, lintScript],
    dependencies: [
        .target(name: "BusAPI"),
        .external(name: "GRDB"),
    ],
    settings: .settings(configurations: configurations)
)

let settings = Settings.settings(configurations: configurations)

let project = Project(
    name: "OffStage",
    settings: settings,
    targets: [busAPI, busAPITests, app],
    schemes: [
        .scheme(
            name: "OffStageApp-Dev",
            buildAction: .buildAction(targets: ["OffStageApp"]),
            runAction: .runAction(configuration: .configuration("Debug-Dev")),
            archiveAction: .archiveAction(configuration: .configuration("Release-Dev"))
        ),
        .scheme(
            name: "OffStageApp",
            buildAction: .buildAction(targets: ["OffStageApp"]),
            runAction: .runAction(configuration: .configuration("Debug-Prod")),
            archiveAction: .archiveAction(configuration: .configuration("Release-Prod"))
        ),
    ]
)
