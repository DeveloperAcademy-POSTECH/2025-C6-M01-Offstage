import BusAPI
import Combine
import Foundation
import Logging
import Moya

@MainActor
final class TestViewModel: ObservableObject {
    // API test state
    @Published var resultText: String = "API Response will be shown here."
    @Published var isLoading = false
    @Published var displayData: Any?

    // Dummy model for playground API calls
    @Published var busStopInfo: BusStopInfo

    private let locationProvider: LocationProviding
    private var cancellables = Set<AnyCancellable>()
    private let networkingApi: NetworkingService = NetworkingAPI.shared

    init(busStopInfo: BusStopInfo? = nil, locationProvider: LocationProviding = LocationManager()) {
        self.busStopInfo = busStopInfo ?? BusStopInfo(
            cityCode: 25, // Daejeon
            nodeId: "DJB8001793", // Daejeon Station Stop
            routeId: "DJB30300002", // Route 2
            stopName: "대전역",
            routeNo: "102",
            gpsLati: 0, // Initial value, will be updated by location services
            gpsLong: 0
        )
        self.locationProvider = locationProvider
    }

    func onAppear() {
        subscribeLocation()
    }

    func resetApiDisplay() {
        displayData = nil
        resultText = "API Response will be shown here."
    }

    func performRequest<T: Codable>(target: TargetType, responseType _: T.Type) async {
        isLoading = true
        resultText = "Loading..."
        displayData = nil

        do {
            let (response, rawData): (ApiResponse<ItemBody<T>>, Data) = try await networkingApi.request(
                target: target,
                responseType: ApiResponse<ItemBody<T>>.self
            )
            if let firstItem = response.response.body?.items.item.first {
                displayData = firstItem
                logInfo("Successfully parsed item: \(String(describing: firstItem))")
                if let rawString = String(data: rawData, encoding: .utf8) {
                    logDebug("Raw response for successful parse: \(rawString)")
                }
                resultText = ""
            } else {
                let rawString = String(data: rawData, encoding: .utf8) ?? "Could not convert data to string"
                resultText = "No items in response.\n\nRaw Response:\n\(rawString)"
            }
        } catch let NetworkError.decodingError(error, data) {
            let dataString = String(data: data, encoding: .utf8) ?? "Could not convert data to string"
            resultText = "Decoding Error: \(error.localizedDescription)\n\nRaw Response:\n\(dataString)"
        } catch {
            resultText = "Error: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func subscribeLocation() {
        guard cancellables.isEmpty else { return }
        locationProvider.requestLocationPermission()

        locationProvider.currentLocation
            .receive(on: RunLoop.main)
            .sink {
                if case let .failure(error) = $0 {
                    // TODO: Surface error to UI when design is ready.
                    logError("Location error: \(error)")
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

    func searchStop() async {
        logInfo("searchStop() called")
        await performRequest(
            target: StopEndpoint.searchStop(cityCode: String(busStopInfo.cityCode), stopName: busStopInfo.stopName),
            responseType: BusStop.self
        )
    }

    func getArrivals() async {
        logInfo("getArrivals() called")
        await performRequest(
            target: ArrivalEndpoint.getArrivals(cityCode: String(busStopInfo.cityCode), nodeId: busStopInfo.nodeId),
            responseType: BusArrivalInfo.self
        )
    }

    func getArrivalsForRoute() async {
        logInfo("getArrivalsForRoute() called")
        await performRequest(
            target: ArrivalEndpoint.getArrivalsForRoute(
                cityCode: String(busStopInfo.cityCode),
                nodeId: busStopInfo.nodeId,
                routeId: busStopInfo.routeId
            ),
            responseType: BusArrivalInfo.self
        )
    }

    func getRouteBusLocations() async {
        logInfo("getRouteBusLocations() called")
        await performRequest(
            target: LocationEndpoint.getRouteBusLocations(
                cityCode: String(busStopInfo.cityCode),
                routeId: busStopInfo.routeId
            ),
            responseType: BusLocation.self
        )
    }

    func getStopsByGPS() async {
        logInfo("getStopsByGPS() called")
        await performRequest(
            target: StopEndpoint.getStopsByGps(gpsLati: busStopInfo.gpsLati, gpsLong: busStopInfo.gpsLong),
            responseType: BusStop.self
        )
    }

    func getStopRoutes() async {
        logInfo("getStopRoutes() called")
        await performRequest(
            target: StopEndpoint.getStopRoutes(cityCode: String(busStopInfo.cityCode), nodeId: busStopInfo.nodeId),
            responseType: StationRoute.self
        )
    }

    func getRouteInfo() async {
        logInfo("getRouteInfo() called")
        await performRequest(
            target: RouteEndpoint.getRouteInfo(cityCode: String(busStopInfo.cityCode), routeId: busStopInfo.routeId),
            responseType: BusRoute.self
        )
    }

    func searchRoute() async {
        logInfo("searchRoute() called")
        await performRequest(
            target: RouteEndpoint.searchRoute(cityCode: String(busStopInfo.cityCode), routeNo: busStopInfo.routeNo),
            responseType: BusRoute.self
        )
    }

    func getRouteStops() async {
        logInfo("getRouteStops() called")
        await performRequest(
            target: RouteEndpoint.getRouteStops(cityCode: String(busStopInfo.cityCode), routeId: busStopInfo.routeId),
            responseType: BusStop.self
        )
    }
}
