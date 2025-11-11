import Foundation

public struct BusRouteStation: Decodable, Hashable, Identifiable {
    public var id: String { stationId }

    public let stationId: String
    public let internalId: String? // 서울 API의 'stId' 등 내부 ID 저장용
    public let stationName: String
    public let stationOrder: Int
    public let turnYn: String?
    public let latitude: Double
    public let longitude: Double

    private enum CodingKeys: String, CodingKey {
        case stationIdLower = "nodeid"
        case stationIdArs = "arsId"
        case internalId = "station"
        case stationNameLower = "nodenm"
        case stationNameUpper = "nodeNm"
        case stationOrderLower = "nodeord"
        case stationOrderUpper = "nodeOrd"
        case stationOrderSeq = "seq"
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
        internalId: String?,
        stationName: String,
        stationOrder: Int,
        turnYn: String?,
        latitude: Double,
        longitude: Double
    ) {
        self.stationId = stationId
        self.internalId = internalId
        self.stationName = stationName
        self.stationOrder = stationOrder
        self.turnYn = turnYn
        self.latitude = latitude
        self.longitude = longitude
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stationId = try container.decodeFlexibleString(forKey: .stationIdLower, fallbackKeys: [.stationIdArs])
        internalId = container.decodeOptionalFlexibleString(forKey: .internalId)
        stationName = try container.decodeFlexibleString(forKey: .stationNameLower, fallbackKeys: [.stationNameUpper])
        stationOrder = try container.decodeFlexibleInt(
            forKey: .stationOrderLower,
            fallbackKeys: [.stationOrderUpper, .stationOrderSeq]
        )
        turnYn = container.decodeOptionalFlexibleString(forKey: .turnYn, fallbackKeys: [.turnYnUpper])

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
