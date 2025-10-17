import Foundation

public struct BusLocation: Codable, Identifiable, Hashable {
    public var id = UUID()
    public let gpslati: Double
    public let gpslong: Double
    public let nodeid: String
    public let nodenm: String
    public let nodeord: Int
    @FlexibleStringDecodable public var routenm: String
    public let routetp: String
    public let vehicleno: String
}
