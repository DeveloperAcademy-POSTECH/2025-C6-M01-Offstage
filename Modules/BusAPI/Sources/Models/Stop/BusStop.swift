import Foundation

public struct BusStop: Codable, Identifiable, Hashable {
    public var id = UUID()
    public let gpslati: Double
    public let gpslong: Double
    public let nodeid: String
    public let nodenm: String
    @OptionalFlexibleStringDecodable public var nodeno: String?
}
