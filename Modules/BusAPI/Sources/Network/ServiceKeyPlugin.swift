import Foundation
import Moya

public struct ServiceKeyPlugin: PluginType {
    public init() {}

    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let busTarget = target as? BusAPITarget,
              let url = request.url,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return request
        }

        if let currentQuery = components.percentEncodedQuery {
            let filtered = currentQuery
                .split(separator: "&")
                .filter { !$0.lowercased().hasPrefix("servicekey=") }
                .joined(separator: "&")
            components.percentEncodedQuery = filtered.isEmpty ? nil : filtered
        }

        let encodedPair = "serviceKey=\(busTarget.serviceKey)"

        if let existing = components.percentEncodedQuery, !existing.isEmpty {
            components.percentEncodedQuery = existing + "&" + encodedPair
        } else {
            components.percentEncodedQuery = encodedPair
        }

        var mutableRequest = request
        mutableRequest.url = components.url
        return mutableRequest
    }
}
