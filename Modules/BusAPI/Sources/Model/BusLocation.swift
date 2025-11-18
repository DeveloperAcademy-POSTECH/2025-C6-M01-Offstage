import Foundation

public struct BusLocation: Decodable, Hashable, Identifiable {
    public var id: String { "\(routeId)-\(vehicleNumber)" }

    public let routeId: String
    public let routeNumber: String
    /// 차량 번호 (예: 서울74사2576)
    public let vehicleNumber: String
    public let nodeId: String
    public let nodeName: String
    public let latitude: Double
    public let longitude: Double

    private enum CodingKeys: String, CodingKey {
        case routeIdLower = "routeid"
        case routeIdUpper = "routeId"
        case routeNumberNameLower = "routenm"
        case routeNumberNameUpper = "routeNm"
        case routeNumberLower = "routeno"
        case routeNumberUpper = "routeNo"
        case vehicleLower = "vehicleno"
        case vehicleUpper = "vehicleNo"
        case vehiclePlain = "plainNo"
        case nodeIdLower = "nodeid"
        case nodeNameLower = "nodenm"
        case nodeNameUpper = "nodeNm"
        case latitudeLower = "gpslati"
        case latitudeUpper = "gpsLati"
        case latitudeY = "gpsY"
        case longitudeLower = "gpslong"
        case longitudeUpper = "gpsLong"
        case longitudeX = "gpsX"
    }

    public init(
        routeId: String,
        routeNumber: String,
        vehicleNumber: String,
        nodeId: String,
        nodeName: String,
        latitude: Double,
        longitude: Double
    ) {
        self.routeId = routeId
        self.routeNumber = routeNumber
        self.vehicleNumber = vehicleNumber
        self.nodeId = nodeId
        self.nodeName = nodeName
        self.latitude = latitude
        self.longitude = longitude
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        routeId = container.decodeOptionalFlexibleString(forKey: .routeIdLower, fallbackKeys: [.routeIdUpper]) ?? ""

        if let number = container.decodeOptionalFlexibleString(
            forKey: .routeNumberLower,
            fallbackKeys: [.routeNumberUpper]
        ) {
            routeNumber = number
        } else {
            routeNumber = container.decodeOptionalFlexibleString(
                forKey: .routeNumberNameLower,
                fallbackKeys: [.routeNumberNameUpper]
            ) ?? ""
        }

        vehicleNumber = container.decodeOptionalFlexibleString(
            forKey: .vehicleLower,
            fallbackKeys: [.vehicleUpper, .vehiclePlain]
        ) ?? ""
        nodeId = container.decodeOptionalFlexibleString(forKey: .nodeIdLower) ?? ""
        nodeName = container.decodeOptionalFlexibleString(forKey: .nodeNameLower, fallbackKeys: [.nodeNameUpper]) ?? ""

        let decodedLatitude = container.decodeOptionalFlexibleDouble(
            forKey: .latitudeLower,
            fallbackKeys: [.latitudeUpper, .latitudeY]
        ) ?? 0
        latitude = decodedLatitude

        let decodedLongitude = container.decodeOptionalFlexibleDouble(
            forKey: .longitudeLower,
            fallbackKeys: [.longitudeUpper, .longitudeX]
        ) ?? 0
        longitude = decodedLongitude
    }
}
