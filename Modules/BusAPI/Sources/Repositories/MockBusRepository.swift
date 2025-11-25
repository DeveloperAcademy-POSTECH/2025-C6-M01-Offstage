import Foundation
import Logging

public final class MockBusRepository: BusRepository {
    private let decoder: JSONDecoder
    private let logger = Logger(label: "BusAPI.MockBusRepository")

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
        logger.info("🎭 MockBusRepository initialized - using mock data")
    }

    public func fetchCities(for _: BusAPIService) async throws -> [BusCity] {
        logger.info("📍 Fetching cities (mock)")
        return try decode(MockData.cities)
    }

    public func fetchRouteLocations(cityCode _: String, routeId: String, page _: Int?) async throws -> [BusLocation] {
        logger.info("📍 Fetching route locations for routeId: \(routeId) (mock)")
        return try decode(MockData.routeLocations)
    }

    public func searchStops(cityCode _: String?, nodeName: String?, nodeNumber: String?) async throws -> [BusStop] {
        logger.info("📍 Searching stops with name: \(nodeName ?? ""), number: \(nodeNumber ?? "") (mock)")
        return try decode(MockData.searchStops)
    }

    public func fetchStopsNearby(latitude: Double, longitude: Double, cityCode _: String?) async throws -> [BusStop] {
        logger.info("📍 Fetching stops nearby lat: \(latitude), lon: \(longitude) (mock)")
        return try decode(MockData.stopsNearby)
    }

    public func fetchRoutesPassingThroughStop(cityCode _: String, nodeId: String) async throws -> [BusRoute] {
        logger.info("📍 Fetching routes passing through stop: \(nodeId) (mock)")
        return try decode(MockData.stopRoutes)
    }

    public func fetchRouteInfo(cityCode _: String, routeId: String) async throws -> BusRoute? {
        logger.info("📍 Fetching route info for routeId: \(routeId) (mock)")
        let routes: [BusRoute] = try decode(MockData.routeInfo)
        return routes.first
    }

    public func searchRoutes(cityCode _: String, routeNumber: String) async throws -> [BusRoute] {
        logger.info("📍 Searching routes with number: \(routeNumber) (mock)")
        return try decode(MockData.searchRoutes)
    }

    public func fetchRouteStations(cityCode _: String, routeId: String) async throws -> [BusRouteStation] {
        logger.info("📍 Fetching route stations for routeId: \(routeId) (mock)")
        return try decode(MockData.routeStations)
    }

    public func fetchStopArrivals(cityCode _: String, nodeId: String) async throws -> [BusArrival] {
        logger.info("📍 Fetching stop arrivals for nodeId: \(nodeId) (mock)")
        return try decode(MockData.stopArrivals)
    }

    public func fetchRouteArrivals(cityCode _: String, nodeId: String, routeId: String) async throws -> [BusArrival] {
        logger.info("📍 Fetching route arrivals for nodeId: \(nodeId), routeId: \(routeId) (mock)")
        return try decode(MockData.routeArrivals)
    }

    private func decode<T: Decodable>(_ jsonString: String) throws -> [T] {
        guard let data = jsonString.data(using: .utf8) else {
            throw BusAPIError.emptyBody
        }

        let envelope = try decoder.decode(BusAPIEnvelope<T>.self, from: data)

        guard envelope.header.isSuccess else {
            throw BusAPIError.invalidStatus(header: envelope.header)
        }

        return envelope.items
    }
}
