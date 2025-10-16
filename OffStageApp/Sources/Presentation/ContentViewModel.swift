import Combine
import Foundation

@MainActor
final class ContentViewModel: ObservableObject {
    // Location display
    @Published var latitude: String = "-"
    @Published var longitude: String = "-"

    // API test state
    @Published var resultText: String = "API Response will be shown here."
    @Published var isLoading = false
    @Published var displayData: Any?
    @Published var isMocking = true

    // Dummy parameters for playground API calls
    let cityCode = "25" // Daejeon
    let nodeId = "DJB8001793" // Daejeon Station Stop
    let routeId = "DJB30300002" // Route 2
    let stopName = "대전역"
    let routeNo = "102"
    let gpsLati = 36.3325
    let gpsLong = 127.4342

    private let locationProvider: LocationProviding
    private var cancellables = Set<AnyCancellable>()

    init(locationProvider: LocationProviding = LocationManager()) {
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
                self?.latitude = String(format: "%.6f", coordinate.latitude)
                self?.longitude = String(format: "%.6f", coordinate.longitude)
            }
            .store(in: &cancellables)
    }

    func searchStop() async {
        await performRequest(
            api: .searchStop(cityCode: cityCode, stopName: stopName),
            responseType: BusStop.self
        )
    }

    func getArrivals() async {
        await performRequest(
            api: .getArrivals(cityCode: cityCode, nodeId: nodeId),
            responseType: BusArrivalInfo.self
        )
    }

    func getArrivalsForRoute() async {
        await performRequest(
            api: .getArrivalsForRoute(cityCode: cityCode, nodeId: nodeId, routeId: routeId),
            responseType: BusArrivalInfo.self
        )
    }

    func getRouteBusLocations() async {
        await performRequest(
            api: .getRouteBusLocations(cityCode: cityCode, routeId: routeId),
            responseType: BusLocation.self
        )
    }

    func getStopsByGPS() async {
        await performRequest(
            api: .getStopsByGps(gpsLati: gpsLati, gpsLong: gpsLong),
            responseType: BusStop.self
        )
    }

    func getStopRoutes() async {
        await performRequest(
            api: .getStopRoutes(cityCode: cityCode, nodeId: nodeId),
            responseType: StationRoute.self
        )
    }

    func getRouteInfo() async {
        await performRequest(
            api: .getRouteInfo(cityCode: cityCode, routeId: routeId),
            responseType: BusRoute.self
        )
    }

    func searchRoute() async {
        await performRequest(
            api: .searchRoute(cityCode: cityCode, routeNo: routeNo),
            responseType: BusRoute.self
        )
    }

    func getRouteStops() async {
        await performRequest(
            api: .getRouteStops(cityCode: cityCode, routeId: routeId),
            responseType: BusStop.self
        )
    }
}
