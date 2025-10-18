import Foundation

/// Represents the combination of stop and route identifiers used across the app.
public struct BusStopInfo: Codable, Hashable {
    public let cityCode: Int
    public let nodeId: String
    public let routeId: String
    public let stopName: String
    public let routeNo: String
    public let gpsLati: Double
    public let gpsLong: Double

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
