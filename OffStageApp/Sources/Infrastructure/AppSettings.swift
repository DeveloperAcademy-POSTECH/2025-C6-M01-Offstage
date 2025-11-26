import Foundation

enum AppSettings {
    private static let useMockDataKey = "useMockData"

    static var useMockData: Bool {
        get {
            UserDefaults.standard.bool(forKey: useMockDataKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: useMockDataKey)
        }
    }
}
