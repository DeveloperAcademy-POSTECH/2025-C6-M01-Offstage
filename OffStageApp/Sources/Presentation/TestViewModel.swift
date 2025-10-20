import BusAPI
import Combine
import Foundation
import Logging

@MainActor
final class TestViewModel: ObservableObject {
    @Published var resultText: String = "API Response will be shown here."
    @Published var isLoading = false
    @Published var displayData: Any?
    @Published var busStopInfo: BusStopInfo

    private let locationProvider: LocationProviding
    private let busRepository: BusRepository
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(label: "TestViewModel")

    init(
        busStopInfo: BusStopInfo? = nil,
        locationProvider: LocationProviding = LocationManager(),
        busRepository: BusRepository = DefaultBusRepository()
    ) {
        self.busStopInfo = busStopInfo ?? BusStopInfo(
            cityCode: 25,
            nodeId: "DJB8001793",
            routeId: "DJB30300002",
            stopName: "대전역",
            routeNo: "102",
            gpsLati: 0,
            gpsLong: 0
        )
        self.locationProvider = locationProvider
        self.busRepository = busRepository
    }

    func onAppear() {
        subscribeLocation()
    }

    func resetApiDisplay() {
        displayData = nil
        resultText = "API Response will be shown here."
    }

    func searchStop() async {
        logger.info("searchStop() called")
        await performRequest(
            name: "Stop search"
        ) {
            try await busRepository.searchStops(
                cityCode: String(busStopInfo.cityCode),
                keyword: busStopInfo.stopName
            )
        } onSuccess: { [weak self] stops in
            guard let self else { return }
            displayData = stops
            resultText = describeStops(stops)
        }
    }

    func getArrivals() async {
        logger.info("getArrivals() called")
        await performRequest(
            name: "Stop arrivals"
        ) {
            try await busRepository.fetchStopArrivals(
                cityCode: String(busStopInfo.cityCode),
                nodeId: busStopInfo.nodeId
            )
        } onSuccess: { [weak self] arrivals in
            guard let self else { return }
            displayData = arrivals
            resultText = describeArrivals(arrivals)
        }
    }

    func getArrivalsForRoute() async {
        logger.info("getArrivalsForRoute() called")
        await performRequest(
            name: "Route-specific arrivals"
        ) {
            try await busRepository.fetchRouteArrivals(
                cityCode: String(busStopInfo.cityCode),
                nodeId: busStopInfo.nodeId,
                routeId: busStopInfo.routeId
            )
        } onSuccess: { [weak self] arrivals in
            guard let self else { return }
            displayData = arrivals
            resultText = describeArrivals(arrivals)
        }
    }

    func getRouteBusLocations() async {
        logger.info("getRouteBusLocations() called")
        await performRequest(
            name: "Route vehicle locations"
        ) {
            try await busRepository.fetchRouteLocations(
                cityCode: String(busStopInfo.cityCode),
                routeId: busStopInfo.routeId,
                page: nil
            )
        } onSuccess: { [weak self] locations in
            guard let self else { return }
            displayData = locations
            resultText = describeLocations(locations)
        }
    }

    func getStopsByGPS() async {
        logger.info("getStopsByGPS() called")
        await performRequest(
            name: "Nearby stops"
        ) {
            try await busRepository.fetchStopsNearby(
                latitude: busStopInfo.gpsLati,
                longitude: busStopInfo.gpsLong
            )
        } onSuccess: { [weak self] stops in
            guard let self else { return }
            displayData = stops
            resultText = describeStops(stops)
        }
    }

    func getStopRoutes() async {
        logger.info("getStopRoutes() called")
        await performRequest(
            name: "Routes by stop"
        ) {
            try await busRepository.fetchRoutesPassingThroughStop(
                cityCode: String(busStopInfo.cityCode),
                nodeId: busStopInfo.nodeId
            )
        } onSuccess: { [weak self] routes in
            guard let self else { return }
            displayData = routes
            resultText = describeRoutes(routes)
        }
    }

    func getRouteInfo() async {
        logger.info("getRouteInfo() called")
        await performRequest(
            name: "Route info"
        ) {
            try await busRepository.fetchRouteInfo(
                cityCode: String(busStopInfo.cityCode),
                routeId: busStopInfo.routeId
            )
        } onSuccess: { [weak self] route in
            guard let self else { return }
            displayData = route as Any
            resultText = describeRoute(route)
        }
    }

    func searchRoute() async {
        logger.info("searchRoute() called")
        await performRequest(
            name: "Route number search"
        ) {
            try await busRepository.searchRoutes(
                cityCode: String(busStopInfo.cityCode),
                routeNumber: busStopInfo.routeNo
            )
        } onSuccess: { [weak self] routes in
            guard let self else { return }
            displayData = routes
            resultText = describeRoutes(routes)
        }
    }

    func getRouteStops() async {
        logger.info("getRouteStops() called")
        await performRequest(
            name: "Route stations"
        ) {
            try await busRepository.fetchRouteStations(
                cityCode: String(busStopInfo.cityCode),
                routeId: busStopInfo.routeId
            )
        } onSuccess: { [weak self] stations in
            guard let self else { return }
            displayData = stations
            resultText = describeStations(stations)
        }
    }

    func getStopCities() async {
        logger.info("getStopCities() called")
        await performRequest(
            name: "Stop city codes"
        ) {
            try await busRepository.fetchCities(for: .stop)
        } onSuccess: { [weak self] cities in
            guard let self else { return }
            displayData = cities
            resultText = describeCities(cities)
        }
    }

    private func subscribeLocation() {
        guard cancellables.isEmpty else { return }
        locationProvider.requestLocationPermission()

        locationProvider.currentLocation
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.logger.error("Location error: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] coordinate in
                guard let self else { return }
                busStopInfo = BusStopInfo(
                    cityCode: busStopInfo.cityCode,
                    nodeId: busStopInfo.nodeId,
                    routeId: busStopInfo.routeId,
                    stopName: busStopInfo.stopName,
                    routeNo: busStopInfo.routeNo,
                    gpsLati: coordinate.latitude,
                    gpsLong: coordinate.longitude
                )
            }
            .store(in: &cancellables)
    }

    private func performRequest<Result>(
        name: String,
        operation: () async throws -> Result,
        onSuccess: (Result) -> Void
    ) async {
        isLoading = true
        resultText = "Loading..."
        displayData = nil
        do {
            let result = try await operation()
            onSuccess(result)
            logger.info("\(name) succeeded")
        } catch {
            handle(error: error, for: name)
        }
        isLoading = false
    }

    private func handle(error: Error, for name: String) {
        if let busError = error as? BusAPIError {
            resultText = "Bus API error: \(busError.localizedDescription)"
        } else {
            resultText = "Error: \(error.localizedDescription)"
        }
        logger.error("\(name) failed: \(error.localizedDescription)")
    }

    private func describeStops(_ stops: [BusStop]) -> String {
        guard let first = stops.first else {
            return "No stops found."
        }
        return "Found \(stops.count) stops. First: \(first.name) (\(first.nodeId))"
    }

    private func describeRoutes(_ routes: [BusRoute]) -> String {
        guard let first = routes.first else {
            return "No routes found."
        }
        return "Found \(routes.count) routes. First: \(first.routeNumber) (\(first.startStopName) -> \(first.endStopName))"
    }

    private func describeRoute(_ route: BusRoute?) -> String {
        guard let route else {
            return "No route found."
        }
        return "\(route.routeNumber) (\(route.startStopName) -> \(route.endStopName))"
    }

    private func describeStations(_ stations: [BusRouteStation]) -> String {
        guard let first = stations.first else {
            return "No stations found."
        }
        return "Found \(stations.count) stations. First: #\(first.stationOrder) \(first.stationName)"
    }

    private func describeArrivals(_ arrivals: [BusArrival]) -> String {
        guard let first = arrivals.first else {
            return "No arrival data found."
        }
        let remaining = first.remainingStopCount.map { "\($0) stops away" } ?? "remaining stops unavailable"
        let eta = first.estimatedArrivalTime.map { "\($0) seconds" } ?? "ETA unavailable"
        return "Found \(arrivals.count) arrivals. First: \(first.routeNumber) - \(remaining), \(eta)"
    }

    private func describeLocations(_ locations: [BusLocation]) -> String {
        guard let first = locations.first else {
            return "No vehicle locations found."
        }
        return "Found \(locations.count) vehicles. First near \(first.nodeName) (\(first.latitude), \(first.longitude))"
    }

    private func describeCities(_ cities: [BusCity]) -> String {
        guard let first = cities.first else {
            return "No city codes found."
        }
        return "Found \(cities.count) cities. First: \(first.name) (\(first.code))"
    }
}
