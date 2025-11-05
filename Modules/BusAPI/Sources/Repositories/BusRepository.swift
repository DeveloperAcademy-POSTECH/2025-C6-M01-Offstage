import Foundation

public protocol BusRepository {
    func searchStops(cityCode: String?, nodeName: String?, nodeNumber: String?) async throws -> [BusStop]
    func fetchStopsNearby(latitude: Double, longitude: Double, cityCode: String?) async throws -> [BusStop]
    func fetchRoutesPassingThroughStop(cityCode: String, nodeId: String) async throws -> [BusRoute]
    func fetchStopArrivals(cityCode: String, nodeId: String) async throws -> [BusArrival]
    func fetchRouteArrivals(cityCode: String, nodeId: String, routeId: String) async throws -> [BusArrival]
}

public extension BusRepository {}
