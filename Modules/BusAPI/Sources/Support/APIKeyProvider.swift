import Foundation

/// Provides access to API keys configured in the host application's Info.plist.
public enum APIKeyProvider {
    /// Returns the bus service key required by the public transportation API.
    /// - Note: The key must be defined in the host app's Info.plist under `Bus Service Key`.
    public static var busServiceKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "Bus Service Key") as? String else {
            fatalError("Info.plist에 Bus Service Key가 설정되지 않았습니다.")
        }
        return key
    }
}
