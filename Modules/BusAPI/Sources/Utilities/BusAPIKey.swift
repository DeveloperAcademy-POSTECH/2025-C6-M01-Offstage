import Foundation

/// The set of Bus API services that require individual service keys.
public enum BusAPIService: CaseIterable {
    case location
    case stop
    case route
    case arrival

    /// Info.plist key used to look up the configured service key.
    public var infoPlistKey: String {
        switch self {
        case .location:
            "LOCATION_SERVICE_KEY"
        case .stop:
            "STOP_SERVICE_KEY"
        case .route:
            "ROUTE_SERVICE_KEY"
        case .arrival:
            "ARRIVAL_SERVICE_KEY"
        }
    }
}

public enum BusAPIKey {
    /// Returns the configured service key for the provided service.
    /// - Parameter service: Service scope that determines which Info.plist key to read.
    /// - Throws: `BusAPIError.missingServiceKey` if the key is absent or empty.
    /// - Returns: Resolved service key string.
    public static func value(for service: BusAPIService) throws -> String {
        for bundle in [Bundle.busAPI, Bundle.main] {
            if let value = string(for: service.infoPlistKey, in: bundle) {
                return value
            }
        }
        throw BusAPIError.missingServiceKey(service)
    }

    /// 서울시 API 키를 반환합니다.
    /// 이 키는 `Project.swift`에 의해 Info.plist로 주입됩니다.
    public static var seoul: String {
        guard let encodedKey = Bundle.main.object(forInfoDictionaryKey: "SEOUL_API_KEY") as? String,
              !encodedKey.isEmpty
        else {
            fatalError("SEOUL_API_KEY가 Info.plist에 설정되지 않았거나 비어있습니다.")
        }

        // Moya가 자체적으로 URL 인코딩을 수행하므로,
        // Info.plist에 저장된 키가 이미 인코딩되어 있다면 이중 인코딩을 방지하기 위해 디코딩합니다.
        if let decodedKey = encodedKey.removingPercentEncoding {
            return decodedKey
        } else {
            // 디코딩에 실패하면(보통 이미 디코딩된 상태), 원본 키를 반환합니다.
            return encodedKey
        }
    }

    /// Indicates whether the provided service has a configured key.
    /// - Parameter service: Service scope to validate.
    /// - Returns: `true` if a non-empty key exists in either the framework or main bundle.
    public static func isConfigured(for service: BusAPIService) -> Bool {
        (try? value(for: service)) != nil
    }

    private static func string(for key: String, in bundle: Bundle) -> String? {
        guard let rawValue = bundle.object(forInfoDictionaryKey: key) as? String else {
            return nil
        }
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
