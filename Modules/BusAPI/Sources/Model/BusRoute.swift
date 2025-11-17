import Foundation

public struct BusRoute: Decodable, Hashable, Identifiable {
    public var id: String { routeId }

    public let routeId: String
    public let routeNumber: String

    private enum CodingKeys: String, CodingKey {
        case routeIdLower = "routeid"
        case routeIdUpper = "routeId"
        case routeNumberLower = "routeno"
        case routeNumberUpper = "routeNo"
    }

    public init(
        routeId: String,
        routeNumber: String
    ) {
        self.routeId = routeId
        self.routeNumber = routeNumber
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        routeId = try container.decodeFlexibleString(forKey: .routeIdLower, fallbackKeys: [.routeIdUpper])
        routeNumber = try container.decodeFlexibleString(forKey: .routeNumberLower, fallbackKeys: [.routeNumberUpper])
    }
}
