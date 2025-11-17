import Foundation

public struct BusArrival: Decodable, Hashable, Identifiable {
    public var id: String { "\(routeId)-\(nodeId)" }

    public let routeId: String
    public let routeNumber: String
    public let nodeId: String
    public let nodeName: String
    public let remainingStopCount: Int?
    public let estimatedArrivalTime: Int?

    private enum CodingKeys: String, CodingKey {
        case routeIdLower = "routeid"
        case routeIdUpper = "routeId"
        case routeNumberLower = "routeno"
        case routeNumberUpper = "routeNo"
        case nodeIdLower = "nodeid"
        case nodeNameLower = "nodenm"
        case nodeNameUpper = "nodeNm"
        case remainingStopsLower = "arrprevstationcnt"
        case remainingStopsUpper = "arrPrevStationCnt"
        case estimatedArrivalLower = "arrtime"
        case estimatedArrivalUpper = "arrTime"
    }

    public init(
        routeId: String,
        routeNumber: String,
        nodeId: String,
        nodeName: String,
        remainingStopCount: Int?,
        estimatedArrivalTime: Int?
    ) {
        self.routeId = routeId
        self.routeNumber = routeNumber
        self.nodeId = nodeId
        self.nodeName = nodeName
        self.remainingStopCount = remainingStopCount
        self.estimatedArrivalTime = estimatedArrivalTime
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        routeId = try container.decodeFlexibleString(forKey: .routeIdLower, fallbackKeys: [.routeIdUpper])
        routeNumber = try container.decodeFlexibleString(forKey: .routeNumberLower, fallbackKeys: [.routeNumberUpper])
        nodeId = try container.decodeFlexibleString(forKey: .nodeIdLower)
        nodeName = try container.decodeFlexibleString(forKey: .nodeNameLower, fallbackKeys: [.nodeNameUpper])
        remainingStopCount = container.decodeOptionalFlexibleInt(
            forKey: .remainingStopsLower,
            fallbackKeys: [.remainingStopsUpper]
        )
        estimatedArrivalTime = container.decodeOptionalFlexibleInt(
            forKey: .estimatedArrivalLower,
            fallbackKeys: [.estimatedArrivalUpper]
        )
    }
}
