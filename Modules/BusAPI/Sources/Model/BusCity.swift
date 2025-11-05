import Foundation

public struct BusCity: Decodable, Hashable {
    public let code: Int
    public let name: String

    private enum CodingKeys: String, CodingKey {
        case codeLower = "citycode"
        case codeUpper = "cityCode"
        case nameLower = "cityname"
        case nameUpper = "cityName"
    }

    public init(code: Int, name: String) {
        self.code = code
        self.name = name
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decodeFlexibleInt(forKey: .codeLower, fallbackKeys: [.codeUpper])
        name = try container.decodeFlexibleString(forKey: .nameLower, fallbackKeys: [.nameUpper])
    }
}
