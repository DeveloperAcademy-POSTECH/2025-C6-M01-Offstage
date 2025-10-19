import Foundation

public struct BusArrivalInfo: Codable, Identifiable, Hashable {
    public var id = UUID()
    public let arrprevstationcnt: Int
    public let arrtime: Int
    public let nodeid: String
    public let nodenm: String
    public let routeid: String
    @FlexibleStringDecodable public var routeno: String
    public let routetp: String
    public let vehicletp: String
}
