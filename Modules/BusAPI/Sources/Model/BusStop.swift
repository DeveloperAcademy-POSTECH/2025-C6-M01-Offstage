import Foundation

public struct BusStop: Decodable, Hashable, Identifiable {
    public var id: String { nodeId }

    public let nodeId: String
    public let name: String
    public let number: String?
    public let cityCode: Int?
    public let direction: String?
    public let latitude: Double
    public let longitude: Double

    private enum CodingKeys: String, CodingKey {
        case nodeIdLower = "nodeid"
        case nodeIdUpper = "nodeId"
        case nameLower = "nodenm"
        case nameUpper = "nodeNm"
        case numberLower = "nodeno"
        case numberUpper = "nodeNo"
        case cityCodeLower = "citycode"
        case cityCodeUpper = "cityCode"
        case directionLegacy = "updowncd"
        case directionModern = "updownCd"
        case directionName = "direction"
        case latitudeLower = "gpslati"
        case latitudeUpper = "gpsLati"
        case latitudeY = "gpsY"
        case longitudeLower = "gpslong"
        case longitudeUpper = "gpsLong"
        case longitudeX = "gpsX"
    }

    public init(
        nodeId: String,
        name: String,
        number: String?,
        cityCode: Int?,
        direction: String?,
        latitude: Double,
        longitude: Double
    ) {
        self.nodeId = nodeId
        self.name = name
        self.number = number
        self.cityCode = cityCode
        self.direction = direction
        self.latitude = latitude
        self.longitude = longitude
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nodeId = try container.decodeFlexibleString(forKey: .nodeIdLower, fallbackKeys: [.nodeIdUpper])
        name = try container.decodeFlexibleString(forKey: .nameLower, fallbackKeys: [.nameUpper])
        number = container.decodeOptionalFlexibleString(forKey: .numberLower, fallbackKeys: [.numberUpper])
        cityCode = container.decodeOptionalFlexibleInt(forKey: .cityCodeLower, fallbackKeys: [.cityCodeUpper])
        direction = container.decodeOptionalFlexibleString(
            forKey: .directionLegacy,
            fallbackKeys: [.directionModern, .directionName]
        )

        guard let decodedLatitude = container.decodeOptionalFlexibleDouble(
            forKey: .latitudeLower,
            fallbackKeys: [.latitudeUpper, .latitudeY]
        ) else {
            throw DecodingError.valueNotFound(
                Double.self,
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "Missing latitude for bus stop"
                )
            )
        }
        latitude = decodedLatitude

        guard let decodedLongitude = container.decodeOptionalFlexibleDouble(
            forKey: .longitudeLower,
            fallbackKeys: [.longitudeUpper, .longitudeX]
        ) else {
            throw DecodingError.valueNotFound(
                Double.self,
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "Missing longitude for bus stop"
                )
            )
        }
        longitude = decodedLongitude
    }
}
