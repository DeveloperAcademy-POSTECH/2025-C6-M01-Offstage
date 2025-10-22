import Foundation

public protocol BusRepository {
    func fetchCities(for service: BusAPIService) async throws -> [BusCity]
    func fetchRouteLocations(cityCode: String, routeId: String, page: Int?) async throws -> [BusLocation]
    func searchStops(cityCode: String, nodeName: String?, nodeNumber: String?) async throws -> [BusStop]
    func fetchStopsNearby(latitude: Double, longitude: Double) async throws -> [BusStop]
    func fetchRoutesPassingThroughStop(cityCode: String, nodeId: String) async throws -> [BusRoute]
    func fetchRouteInfo(cityCode: String, routeId: String) async throws -> BusRoute?
    func searchRoutes(cityCode: String, routeNumber: String) async throws -> [BusRoute]
    func fetchRouteStations(cityCode: String, routeId: String) async throws -> [BusRouteStation]
    func fetchStopArrivals(cityCode: String, nodeId: String) async throws -> [BusArrival]
    func fetchRouteArrivals(cityCode: String, nodeId: String, routeId: String) async throws -> [BusArrival]
}

public extension BusRepository {
    func fetchRouteLocations(cityCode: String, routeId: String) async throws -> [BusLocation] {
        try await fetchRouteLocations(cityCode: cityCode, routeId: routeId, page: nil)
    }

    func searchStops(cityCode: String, keyword: String) async throws -> [BusStop] {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let isNumeric = trimmed.allSatisfy(\.isNumber)
        let nodeName = isNumeric ? nil : trimmed
        let nodeNumber = isNumeric ? trimmed : nil
        return try await searchStops(cityCode: cityCode, nodeName: nodeName, nodeNumber: nodeNumber)
    }
}
