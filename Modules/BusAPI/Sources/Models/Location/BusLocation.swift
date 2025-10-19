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

public extension BusLocation {
    static var sample: BusLocation {
        .init(
            gpslati: 36.3325,
            gpslong: 127.4342,
            nodeid: "DJB8001793",
            nodenm: "대전역",
            nodeord: 1,
            routenm: "102",
            routetp: "간선버스",
            vehicleno: "대전75자1234"
        )
    }
}
