import Foundation

public final class MainBusRepository: BusRepository {
    private let tagoRepository: BusRepository
    private let seoulRepository: BusRepository

    public init(
        tagoRepository: BusRepository = TagoBusRepository(),
        seoulRepository: BusRepository = SeoulBusRepository()
    ) {
        self.tagoRepository = tagoRepository
        self.seoulRepository = seoulRepository
    }

    // MARK: - BusRepository conformance

    public func searchStops(cityCode: String?, nodeName: String?, nodeNumber: String?) async throws -> [BusStop] {
        if cityCode == "1000" {
            return try await seoulRepository.searchStops(cityCode: cityCode, nodeName: nodeName, nodeNumber: nodeNumber)
        }
        return try await tagoRepository.searchStops(cityCode: cityCode, nodeName: nodeName, nodeNumber: nodeNumber)
    }

    public func fetchStopsNearby(latitude: Double, longitude: Double, cityCode: String?) async throws -> [BusStop] {
        if cityCode == "1000" {
            return try await seoulRepository.fetchStopsNearby(
                latitude: latitude,
                longitude: longitude,
                cityCode: cityCode
            )
        }
        return try await tagoRepository.fetchStopsNearby(latitude: latitude, longitude: longitude, cityCode: cityCode)
    }

    public func fetchRoutesPassingThroughStop(cityCode: String, nodeId: String) async throws -> [BusRoute] {
        if cityCode == "1000" {
            return try await seoulRepository.fetchRoutesPassingThroughStop(cityCode: cityCode, nodeId: nodeId)
        }
        return try await tagoRepository.fetchRoutesPassingThroughStop(cityCode: cityCode, nodeId: nodeId)
    }

    public func fetchStopArrivals(cityCode: String, nodeId: String) async throws -> [BusArrival] {
        if cityCode == "1000" {
            return try await seoulRepository.fetchStopArrivals(cityCode: cityCode, nodeId: nodeId)
        }
        return try await tagoRepository.fetchStopArrivals(cityCode: cityCode, nodeId: nodeId)
    }

    public func fetchRouteArrivals(cityCode: String, nodeId: String, routeId: String) async throws -> [BusArrival] {
        if cityCode == "1000" {
            return try await seoulRepository.fetchRouteArrivals(cityCode: cityCode, nodeId: nodeId, routeId: routeId)
        }
        return try await tagoRepository.fetchRouteArrivals(cityCode: cityCode, nodeId: nodeId, routeId: routeId)
    }
}
