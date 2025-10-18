import Combine
import Foundation

@MainActor
final class TestViewModel: ObservableObject {
    // API test state
    @Published var resultText: String = "API Response will be shown here."
    @Published var isLoading = false
    @Published var displayData: Any?
    @Published var isMocking = true

    // Dummy model for playground API calls
    @Published var busStopInfo: BusStopInfo

    private let locationProvider: LocationProviding
    private var cancellables = Set<AnyCancellable>()

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

    func performRequest<T: Codable>(api: BusAPI, responseType _: T.Type) async {
        isLoading = true
        resultText = "Loading..."
        displayData = nil

        do {
            let response: ApiResponse<ItemBody<T>> = try await networkingApi.request(api: api)
            if let firstItem = response.response.body?.items.item.first {
                displayData = firstItem
                resultText = ""
            } else {
                resultText = "No items in response"
            }
        } catch let NetworkError.decodingError(error, data) {
            let dataString = String(data: data, encoding: .utf8) ?? "Could not convert data to string"
            resultText = "Decoding Error: \(error.localizedDescription)\n\nRaw Response:\n\(dataString)"
        } catch {
            resultText = "Error: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private var networkingApi: NetworkingAPI {
        NetworkingAPI(isMocking: isMocking)
    }

    private func subscribeLocation() {
        guard cancellables.isEmpty else { return }
        locationProvider.requestLocationPermission()

        locationProvider.currentLocation
            .receive(on: RunLoop.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    // TODO: Surface error to UI when design is ready.
                    print("Location error: \(error)")
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
        await performRequest(
            api: .searchStop(cityCode: String(busStopInfo.cityCode), stopName: busStopInfo.stopName),
            responseType: BusStop.self
        )
    }

    func getArrivals() async {
        await performRequest(
            api: .getArrivals(cityCode: String(busStopInfo.cityCode), nodeId: busStopInfo.nodeId),
            responseType: BusArrivalInfo.self
        )
    }

    func getArrivalsForRoute() async {
        await performRequest(
            api: .getArrivalsForRoute(
                cityCode: String(busStopInfo.cityCode),
                nodeId: busStopInfo.nodeId,
                routeId: busStopInfo.routeId
            ),
            responseType: BusArrivalInfo.self
        )
    }

    func getRouteBusLocations() async {
        await performRequest(
            api: .getRouteBusLocations(cityCode: String(busStopInfo.cityCode), routeId: busStopInfo.routeId),
            responseType: BusLocation.self
        )
    }

    func getStopsByGPS() async {
        await performRequest(
            api: .getStopsByGps(gpsLati: busStopInfo.gpsLati, gpsLong: busStopInfo.gpsLong),
            responseType: BusStop.self
        )
    }

    func getStopRoutes() async {
        await performRequest(
            api: .getStopRoutes(cityCode: String(busStopInfo.cityCode), nodeId: busStopInfo.nodeId),
            responseType: StationRoute.self
        )
    }

    func getRouteInfo() async {
        await performRequest(
            api: .getRouteInfo(cityCode: String(busStopInfo.cityCode), routeId: busStopInfo.routeId),
            responseType: BusRoute.self
        )
    }

    func searchRoute() async {
        await performRequest(
            api: .searchRoute(cityCode: String(busStopInfo.cityCode), routeNo: busStopInfo.routeNo),
            responseType: BusRoute.self
        )
    }

    func getRouteStops() async {
        await performRequest(
            api: .getRouteStops(cityCode: String(busStopInfo.cityCode), routeId: busStopInfo.routeId),
            responseType: BusStop.self
        )
    }
}
