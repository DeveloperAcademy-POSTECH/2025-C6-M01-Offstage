import Foundation

public struct BusStop: Codable, Identifiable, Hashable {
    public var id = UUID()
    public let gpslati: Double
    public let gpslong: Double
    public let nodeid: String
    public let nodenm: String
    @OptionalFlexibleStringDecodable public var nodeno: String?
}

public extension BusStop {
    static var sample: BusStop {
        .init(gpslati: 36.3325, gpslong: 127.4342, nodeid: "DJB8001793", nodenm: "대전역", nodeno: "101")
    }
}
