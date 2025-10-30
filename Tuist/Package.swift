// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    // 1. Configuration을 정의하기 위해 import
    import struct ProjectDescription.Configuration

    // 2. Project.swift와 "이름"을 동일하게 맞춘 Configuration 배열을 정의합니다.
    // (중요: 여기서는 .xcconfig 파일을 연결할 필요가 없습니다.
    // 의존성들은 이 "이름"의 구성으로 빌드되기만 하면 됩니다.)
    let configurations: [Configuration] = [
        .debug(name: "Debug-Dev"),
        .release(name: "Release-Dev"),
        .debug(name: "Debug-Prod"),
        .release(name: "Release-Prod"),
    ]

    let packageSettings = PackageSettings(
        productTypes: [
            // (권장) 안정적인 빌드를 위해 동적 프레임워크로 강제
            "Moya": .framework,
            "Logging": .framework,
            "GRDB": .framework,
            "Alamofire": .framework,
            "RxSwift": .framework,
            "ReactiveSwift": .framework,
        ],

        // 3. (핵심) 모든 SPM 의존성들이
        //    기본 'Debug/Release' 대신 위 4개의 Configuration을 사용하도록
        //    baseSettings를 설정합니다.
        baseSettings: .settings(
            configurations: configurations
        )
    )
#endif

// 4. 기존 dependencies 정의 (변경 없음)
let package = Package(
    name: "OffStageApp",
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.25.0"),
    ]
)
