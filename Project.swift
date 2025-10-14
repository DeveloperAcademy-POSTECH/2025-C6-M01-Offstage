import ProjectDescription

let organizationName = "c6.offstage"

let baseInfoPlist: [String: Plist.Value] = [
    "UILaunchScreen": [
        "UIColorName": "",
        "UIImageName": "",
    ],
    "CFBundleShortVersionString": "1.0",
    "CFBundleVersion": "1",
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
    destinations: [.iPhone, .iPad],
    product: .unitTests,
    bundleId: "\(organizationName).BusApiTest",
    infoPlist: .default,
    sources: ["Modules/BusApiTest/**"],
    dependencies: []
)

let app = Target.target(
    name: "OffStageApp",
    destinations: [.iPhone, .iPad],
    product: .app,
    bundleId: "\(organizationName).App",
    infoPlist: .extendingDefault(with: baseInfoPlist),
    sources: ["OffStageApp/Sources/**"],
    resources: ["OffStageApp/Resources/**"],
    scripts: [formatScript, lintScript],
    dependencies: [
    ]
)

let busAI = Target.target(
    name: "BusAI",
    destinations: [.iPhone, .iPad],
    product: .app,
    bundleId: "\(organizationName).BusAI",
    infoPlist: .extendingDefault(with: baseInfoPlist),
    sources: ["BusAI/Sources/**"],
    resources: ["BusAI/Resources/**"],
    scripts: [formatScript, lintScript],
)

let project = Project(
    name: "OffStage",
    targets: [app, busAI, busApiTest]
)
