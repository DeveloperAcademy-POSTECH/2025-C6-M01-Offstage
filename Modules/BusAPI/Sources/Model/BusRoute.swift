import Foundation

public struct BusRoute: Decodable, Hashable, Identifiable {
    public var id: String { routeId }

    public let routeId: String
    public let routeNumber: String
    public let routeType: String
    public let startStopName: String
    public let endStopName: String
    public let startTime: String?
    public let endTime: String?

    private enum CodingKeys: String, CodingKey {
        case routeIdLower = "routeid"
        case routeIdUpper = "routeId"
        case routeNumberLower = "routeno"
        case routeNumberUpper = "routeNo"
        case routeTypeLower = "routetp"
        case routeTypeUpper = "routeTp"
        case startStopLower = "startnodenm"
        case startStopUpper = "startNodeNm"
        case endStopLower = "endnodenm"
        case endStopUpper = "endNodeNm"
        case startTimeLower = "startvehicletime"
        case startTimeUpper = "startVehicleTime"
        case endTimeLower = "endvehicletime"
        case endTimeUpper = "endVehicleTime"
    }

    public init(
        routeId: String,
        routeNumber: String,
        routeType: String,
        startStopName: String,
        endStopName: String,
        startTime: String?,
        endTime: String?
    ) {
        self.routeId = routeId
        self.routeNumber = routeNumber
        self.routeType = routeType
        self.startStopName = startStopName
        self.endStopName = endStopName
        self.startTime = startTime
        self.endTime = endTime
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        routeId = try container.decodeFlexibleString(forKey: .routeIdLower, fallbackKeys: [.routeIdUpper])
        routeNumber = try container.decodeFlexibleString(forKey: .routeNumberLower, fallbackKeys: [.routeNumberUpper])
        routeType = try container.decodeFlexibleString(forKey: .routeTypeLower, fallbackKeys: [.routeTypeUpper])
        startStopName = try container.decodeFlexibleString(forKey: .startStopLower, fallbackKeys: [.startStopUpper])
        endStopName = try container.decodeFlexibleString(forKey: .endStopLower, fallbackKeys: [.endStopUpper])
        startTime = container.decodeOptionalFlexibleString(forKey: .startTimeLower, fallbackKeys: [.startTimeUpper])
        endTime = container.decodeOptionalFlexibleString(forKey: .endTimeLower, fallbackKeys: [.endTimeUpper])
    }
}
