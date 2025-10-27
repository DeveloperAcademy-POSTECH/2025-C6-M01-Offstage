import Foundation

public struct BusArrival: Decodable, Hashable, Identifiable {
    public var id: String { "\(routeId)-\(nodeId)" }

    public let routeId: String
    public let routeNumber: String
    public let routeType: String
    public let nodeId: String
    public let nodeName: String
    public let remainingStopCount: Int?
    public let estimatedArrivalTime: Int?
    public let vehicleType: String?

    private enum CodingKeys: String, CodingKey {
        case routeIdLower = "routeid"
        case routeIdUpper = "routeId"
        case routeNumberLower = "routeno"
        case routeNumberUpper = "routeNo"
        case routeTypeLower = "routetp"
        case routeTypeUpper = "routeTp"
        case nodeIdLower = "nodeid"
        case nodeNameLower = "nodenm"
        case nodeNameUpper = "nodeNm"
        case remainingStopsLower = "arrprevstationcnt"
        case remainingStopsUpper = "arrPrevStationCnt"
        case estimatedArrivalLower = "arrtime"
        case estimatedArrivalUpper = "arrTime"
        case vehicleLower = "vehicletp"
        case vehicleUpper = "vehicleTp"
    }

    public init(
        routeId: String,
        routeNumber: String,
        routeType: String,
        nodeId: String,
        nodeName: String,
        remainingStopCount: Int?,
        estimatedArrivalTime: Int?,
        vehicleType: String?
    ) {
        self.routeId = routeId
        self.routeNumber = routeNumber
        self.routeType = routeType
        self.nodeId = nodeId
        self.nodeName = nodeName
        self.remainingStopCount = remainingStopCount
        self.estimatedArrivalTime = estimatedArrivalTime
        self.vehicleType = vehicleType
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        routeId = try container.decodeFlexibleString(forKey: .routeIdLower, fallbackKeys: [.routeIdUpper])
        routeNumber = try container.decodeFlexibleString(forKey: .routeNumberLower, fallbackKeys: [.routeNumberUpper])
        routeType = try container.decodeFlexibleString(forKey: .routeTypeLower, fallbackKeys: [.routeTypeUpper])
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
        vehicleType = container.decodeOptionalFlexibleString(forKey: .vehicleLower, fallbackKeys: [.vehicleUpper])
    }
}
