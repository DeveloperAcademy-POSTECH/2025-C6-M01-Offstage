import Foundation

public struct StationRoute: Codable, Identifiable, Hashable {
    public var id = UUID()
    public let routeid: String
    @FlexibleStringDecodable public var routeno: String
    public let routetp: String
    public let startnodenm: String
    public let endnodenm: String
}

public extension StationRoute {
    static var sample: StationRoute {
        .init(routeid: "DJB30300002", routeno: "2", routetp: "간선버스", startnodenm: "기점", endnodenm: "종점")
    }
}
