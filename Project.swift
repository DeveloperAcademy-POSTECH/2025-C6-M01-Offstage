import ProjectDescription

let organizationName = "2025C6.OffStage"

let baseInfoPlist: [String: Plist.Value] = [
    "UILaunchScreen": [
        "UIColorName": "",
        "UIImageName": "",
    ],
    "CFBundleShortVersionString": "1.0",
    "CFBundleVersion": "1",
    "Bus Service Key": "$(SERVICE_KEY)",
    "NSLocationWhenInUseUsageDescription": "현재 위치를 기반으로 주변 정류장 정보를 제공하기 위해 위치 정보가 필요합니다.",
    "ITSAppUsesNonExemptEncryption": .boolean(false),
    "UIDesignRequiresCompatibility": .boolean(true),
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

let busApiTest = Target.target(
    name: "BusApiTest",
    destinations: [.iPhone],
    product: .unitTests,
    bundleId: "\(organizationName).BusApiTest",
    infoPlist: .default,
    sources: ["Modules/BusApiTest/**"],
    dependencies: []
)

let app = Target.target(
    name: "OffStageApp",
    destinations: [.iPhone],
    product: .app,
    bundleId: "\(organizationName).App",
    infoPlist: .extendingDefault(with: baseInfoPlist),
    sources: ["OffStageApp/Sources/**"],
    resources: ["OffStageApp/Resources/**"],
    scripts: [formatScript, lintScript],
    dependencies: [
        .external(name: "Moya"),
    ]
)

let busAI = Target.target(
    name: "BusAI",
    destinations: [.iPhone],
    product: .app,
    bundleId: "\(organizationName).BusAI",
    infoPlist: .extendingDefault(with: baseInfoPlist),
    sources: ["BusAI/Sources/**"],
    resources: ["BusAI/Resources/**"],
    scripts: [formatScript, lintScript],
)

let settings = Settings.settings(
    base: [:],
    configurations: [
        .debug(name: "Debug", xcconfig: .relativeToRoot("Config/Debug.xcconfig")),
        .release(name: "Release", xcconfig: .relativeToRoot("Config/Release.xcconfig")),
    ]
)

let project = Project(
    name: "OffStage",
    settings: settings,
    targets: [app, busAI, busApiTest]
)
