import Foundation

private final class BusAPIBundleToken {}

public extension Bundle {
    /// The bundle that contains the BusAPI resources (e.g., Info.plist for keys).
    static let busAPI: Bundle = {
        let candidate = Bundle(for: BusAPIBundleToken.self)
        if let resourceURL = candidate.url(forResource: "BusAPI", withExtension: "bundle"),
           let bundle = Bundle(url: resourceURL)
        {
            return bundle
        }
        return candidate
    }()
}
