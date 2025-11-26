import BusAPI
import Foundation

public final class MainBusRepository: BusRepository {
    #if DEBUG_MODE
        private let mockRepository = MockBusRepository()
    #endif
    private lazy var realTagoRepository = TagoBusRepository()
    private lazy var realSeoulRepository = SeoulBusRepository()

    private var tagoRepository: BusRepository {
        shouldUseMock ? mockRepository : realTagoRepository
    }

    private var seoulRepository: BusRepository {
        shouldUseMock ? mockRepository : realSeoulRepository
    }

    public init() {}

    private var shouldUseMock: Bool {
        #if DEBUG_MODE
            UserDefaults.standard.bool(forKey: "useMockData")
        #else
            false
        #endif
    }

    // MARK: - BusRepository conformance

    public func fetchCities(for service: BusAPIService) async throws -> [BusCity] {
        try await tagoRepository.fetchCities(for: service)
    }

    public func fetchRouteLocations(cityCode: String, routeId: String, page: Int?) async throws -> [BusLocation] {
        try await tagoRepository.fetchRouteLocations(cityCode: cityCode, routeId: routeId, page: page)
    }

    public func searchStops(cityCode: String?, nodeName: String?, nodeNumber: String?) async throws -> [BusStop] {
        let repository = cityCode == "1000" ? seoulRepository : tagoRepository
        return try await repository.searchStops(cityCode: cityCode, nodeName: nodeName, nodeNumber: nodeNumber)
    }

    public func fetchStopsNearby(latitude: Double, longitude: Double, cityCode: String?) async throws -> [BusStop] {
        let repository = cityCode == "1000" ? seoulRepository : tagoRepository
        return try await repository.fetchStopsNearby(latitude: latitude, longitude: longitude, cityCode: cityCode)
    }

    public func fetchRoutesPassingThroughStop(cityCode: String, nodeId: String) async throws -> [BusRoute] {
        let repository = cityCode == "1000" ? seoulRepository : tagoRepository
        return try await repository.fetchRoutesPassingThroughStop(cityCode: cityCode, nodeId: nodeId)
    }

    public func fetchRouteInfo(cityCode: String, routeId: String) async throws -> BusRoute? {
        let repository = cityCode == "1000" ? seoulRepository : tagoRepository
        return try await repository.fetchRouteInfo(cityCode: cityCode, routeId: routeId)
    }

    public func searchRoutes(cityCode: String, routeNumber: String) async throws -> [BusRoute] {
        let repository = cityCode == "1000" ? seoulRepository : tagoRepository
        return try await repository.searchRoutes(cityCode: cityCode, routeNumber: routeNumber)
    }

    public func fetchRouteStations(cityCode: String, routeId: String) async throws -> [BusRouteStation] {
        let repository = cityCode == "1000" ? seoulRepository : tagoRepository
        return try await repository.fetchRouteStations(cityCode: cityCode, routeId: routeId)
    }

    public func fetchStopArrivals(cityCode: String, nodeId: String) async throws -> [BusArrival] {
        let repository = cityCode == "1000" ? seoulRepository : tagoRepository
        return try await repository.fetchStopArrivals(cityCode: cityCode, nodeId: nodeId)
    }

    public func fetchRouteArrivals(cityCode: String, nodeId: String, routeId: String) async throws -> [BusArrival] {
        let repository = cityCode == "1000" ? seoulRepository : tagoRepository
        return try await repository.fetchRouteArrivals(cityCode: cityCode, nodeId: nodeId, routeId: routeId)
    }
}
