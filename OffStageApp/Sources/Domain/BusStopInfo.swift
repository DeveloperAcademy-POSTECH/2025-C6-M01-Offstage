import Foundation

public struct BusStopInfo: Equatable, Sendable, Hashable {
    public var cityCode: Int
    public var nodeId: String
    public var routeId: String
    public var stopName: String
    public var routeNo: String
    public var gpsLati: Double
    public var gpsLong: Double

    public init(
        cityCode: Int,
        nodeId: String,
        routeId: String,
        stopName: String,
        routeNo: String,
        gpsLati: Double,
        gpsLong: Double
    ) {
        self.cityCode = cityCode
        self.nodeId = nodeId
        self.routeId = routeId
        self.stopName = stopName
        self.routeNo = routeNo
        self.gpsLati = gpsLati
        self.gpsLong = gpsLong
    }
}
