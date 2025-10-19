import Foundation

public struct BusRoute: Codable, Identifiable, Hashable {
    public var id = UUID()
    public let routeid: String
    @FlexibleStringDecodable public var routeno: String
    public let routetp: String
    public let startnodenm: String
    public let endnodenm: String
    @OptionalFlexibleStringDecodable public var startvehicletime: String?
    @OptionalFlexibleStringDecodable public var endvehicletime: String?
}

public extension BusRoute {
    static var sample: BusRoute {
        .init(
            routeid: "DJB30300002",
            routeno: "2",
            routetp: "간선버스",
            startnodenm: "기점",
            endnodenm: "종점",
            startvehicletime: "05:30",
            endvehicletime: "22:00"
        )
    }
}
