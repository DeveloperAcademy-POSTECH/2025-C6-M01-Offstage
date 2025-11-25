import Foundation
import Logging

public final class MockBusRepository: BusRepository {
    private let logger = Logger(label: "BusAPI.MockBusRepository")

    public init() {
        logger.info("🎭 MockBusRepository initialized - using mock data")
    }

    public func fetchCities(for _: BusAPIService) async throws -> [BusCity] {
        logger.info("📍 Fetching cities (mock)")
        return MockData.cities
    }

    public func fetchRouteLocations(cityCode _: String, routeId: String, page _: Int?) async throws -> [BusLocation] {
        logger.info("📍 Fetching route locations for routeId: \(routeId) (mock)")
        return MockData.routeLocations
    }

    public func searchStops(cityCode _: String?, nodeName: String?, nodeNumber: String?) async throws -> [BusStop] {
        logger.info("📍 Searching stops with name: \(nodeName ?? ""), number: \(nodeNumber ?? "") (mock)")
        return MockData.searchStops
    }

    public func fetchStopsNearby(latitude: Double, longitude: Double, cityCode _: String?) async throws -> [BusStop] {
        logger.info("📍 Fetching stops nearby lat: \(latitude), lon: \(longitude) (mock)")
        return MockData.stopsNearby
    }

    public func fetchRoutesPassingThroughStop(cityCode _: String, nodeId: String) async throws -> [BusRoute] {
        logger.info("📍 Fetching routes passing through stop: \(nodeId) (mock)")

        let routes = BusScheduleSimulator.getRoutesForStop(nodeId: nodeId)
        return routes.map { route in
            BusRoute(
                routeId: route.routeId,
                routeNumber: route.routeNumber
            )
        }
    }

    public func fetchRouteInfo(cityCode _: String, routeId: String) async throws -> BusRoute? {
        logger.info("📍 Fetching route info for routeId: \(routeId) (mock)")
        return MockData.routeInfo.first
    }

    public func searchRoutes(cityCode _: String, routeNumber: String) async throws -> [BusRoute] {
        logger.info("📍 Searching routes with number: \(routeNumber) (mock)")
        return MockData.searchRoutes
    }

    public func fetchRouteStations(cityCode _: String, routeId: String) async throws -> [BusRouteStation] {
        logger.info("📍 Fetching route stations for routeId: \(routeId) (mock)")
        return MockData.routeStations
    }

    public func fetchStopArrivals(cityCode _: String, nodeId: String) async throws -> [BusArrival] {
        logger.info("📍 Fetching stop arrivals for nodeId: \(nodeId) (mock with schedule)")

        let arrivals = BusScheduleSimulator.calculateArrivals(for: nodeId)
        return arrivals.map { arrival in
            BusArrival(
                routeId: arrival.routeId,
                routeNumber: arrival.routeNumber,
                nodeId: arrival.nodeId,
                nodeName: arrival.nodeName,
                remainingStopCount: arrival.remainingStops,
                estimatedArrivalTime: arrival.arrivalTime
            )
        }
    }

    public func fetchRouteArrivals(cityCode _: String, nodeId: String, routeId: String) async throws -> [BusArrival] {
        logger.info("📍 Fetching route arrivals for nodeId: \(nodeId), routeId: \(routeId) (mock with schedule)")

        guard let arrival = BusScheduleSimulator.calculateArrival(routeId: routeId, nodeId: nodeId) else {
            return []
        }

        return [BusArrival(
            routeId: arrival.routeId,
            routeNumber: arrival.routeNumber,
            nodeId: arrival.nodeId,
            nodeName: arrival.nodeName,
            remainingStopCount: arrival.remainingStops,
            estimatedArrivalTime: arrival.arrivalTime
        )]
    }
}
