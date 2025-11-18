import Foundation

public struct BusRouteStation: Decodable, Hashable, Identifiable {
    public var id: String { stationId }

    public let stationId: String
    public let stationName: String
    public let latitude: Double
    public let longitude: Double

    private enum CodingKeys: String, CodingKey {
        case stationIdLower = "nodeid"
        case stationIdArs = "arsId"
        case stationNameLower = "nodenm"
        case stationNameUpper = "nodeNm"
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
        latitude: Double,
        longitude: Double
    ) {
        self.stationId = stationId
        self.stationName = stationName
        self.latitude = latitude
        self.longitude = longitude
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stationId = try container.decodeFlexibleString(
            forKey: .stationIdLower,
            fallbackKeys: [.stationIdArs]
        )
        stationName = try container.decodeFlexibleString(forKey: .stationNameLower, fallbackKeys: [.stationNameUpper])

        let decodedLatitude = container.decodeOptionalFlexibleDouble(
            forKey: .latitudeLower,
            fallbackKeys: [.latitudeUpper, .latitudeY]
        )
        latitude = decodedLatitude ?? 0.0 // 서울 API는 좌표 미제공

        let decodedLongitude = container.decodeOptionalFlexibleDouble(
            forKey: .longitudeLower,
            fallbackKeys: [.longitudeUpper, .longitudeX]
        )
        longitude = decodedLongitude ?? 0.0 // 서울 API는 좌표 미제공
    }
}
