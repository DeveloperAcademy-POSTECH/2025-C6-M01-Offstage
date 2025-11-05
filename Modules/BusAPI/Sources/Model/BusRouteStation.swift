import Foundation

public struct BusRouteStation: Decodable, Hashable, Identifiable {
    public var id: String { stationId }

    public let stationId: String
    public let stationName: String
    public let stationOrder: Int
    public let turnYn: String?
    public let latitude: Double
    public let longitude: Double

    private enum CodingKeys: String, CodingKey {
        case stationIdLower = "nodeid"
        case stationNameLower = "nodenm"
        case stationNameUpper = "nodeNm"
        case stationOrderLower = "nodeord"
        case stationOrderUpper = "nodeOrd"
        case turnYn
        case turnYnUpper = "turnYN"
        case latitudeLower = "gpslati"
        case latitudeUpper = "gpsLati"
        case latitudeY = "gpsY"
        case longitudeLower = "gpslong"
        case longitudeUpper = "gpsLong"
        case longitudeX = "gpsX"
    }

    public init(
        stationId: String,
        stationName: String,
        stationOrder: Int,
        turnYn: String?,
        latitude: Double,
        longitude: Double
    ) {
        self.stationId = stationId
        self.stationName = stationName
        self.stationOrder = stationOrder
        self.turnYn = turnYn
        self.latitude = latitude
        self.longitude = longitude
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stationId = try container.decodeFlexibleString(forKey: .stationIdLower)
        stationName = try container.decodeFlexibleString(forKey: .stationNameLower, fallbackKeys: [.stationNameUpper])
        stationOrder = try container.decodeFlexibleInt(forKey: .stationOrderLower, fallbackKeys: [.stationOrderUpper])
        turnYn = container.decodeOptionalFlexibleString(forKey: .turnYn, fallbackKeys: [.turnYnUpper])

        guard let decodedLatitude = container.decodeOptionalFlexibleDouble(
            forKey: .latitudeLower,
            fallbackKeys: [.latitudeUpper, .latitudeY]
        ) else {
            throw DecodingError.valueNotFound(
                Double.self,
                .init(codingPath: container.codingPath, debugDescription: "Missing latitude for route station")
            )
        }
        latitude = decodedLatitude

        guard let decodedLongitude = container.decodeOptionalFlexibleDouble(
            forKey: .longitudeLower,
            fallbackKeys: [.longitudeUpper, .longitudeX]
        ) else {
            throw DecodingError.valueNotFound(
                Double.self,
                .init(codingPath: container.codingPath, debugDescription: "Missing longitude for route station")
            )
        }
        longitude = decodedLongitude
    }
}
