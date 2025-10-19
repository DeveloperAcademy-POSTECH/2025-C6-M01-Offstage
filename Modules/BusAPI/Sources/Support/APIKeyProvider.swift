import Foundation

/// Provides access to API keys configured in the host application's Info.plist.
public enum APIKeyProvider {
    /// Returns the arrival service key.
    public static var arrivalServiceKey: String {
        serviceKey(for: "ArrivalServiceKey")
    }

    /// Returns the location service key.
    public static var locationServiceKey: String {
        serviceKey(for: "LocationServiceKey")
    }

    /// Returns the stop service key.
    public static var stopServiceKey: String {
        serviceKey(for: "StopServiceKey")
    }

    /// Returns the route service key.
    public static var routeServiceKey: String {
        serviceKey(for: "RouteServiceKey")
    }

    /// Helper function to retrieve a key from the main bundle's Info.plist.
    /// - Parameter keyName: The name of the key to retrieve.
    /// - Returns: The value of the key.
    private static func serviceKey(for keyName: String) -> String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: keyName) as? String, !key.isEmpty else {
            fatalError("Info.plist에 \(keyName)가 설정되지 않았거나 비어있습니다.")
        }
        return key
    }
}
