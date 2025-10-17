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
