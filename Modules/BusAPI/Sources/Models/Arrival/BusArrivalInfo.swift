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

public extension BusArrivalInfo {
    static var sample: BusArrivalInfo {
        .init(
            arrprevstationcnt: 1,
            arrtime: 91,
            nodeid: "DJB8001793",
            nodenm: "대전역",
            routeid: "DJB30300002",
            routeno: "2",
            routetp: "간선버스",
            vehicletp: "저상버스"
        )
    }
}
