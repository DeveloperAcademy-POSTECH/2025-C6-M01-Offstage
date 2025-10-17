import Foundation

public struct StationRoute: Codable, Identifiable, Hashable {
    public var id = UUID()
    public let routeid: String
    @FlexibleStringDecodable public var routeno: String
    public let routetp: String
    public let startnodenm: String
    public let endnodenm: String
}
