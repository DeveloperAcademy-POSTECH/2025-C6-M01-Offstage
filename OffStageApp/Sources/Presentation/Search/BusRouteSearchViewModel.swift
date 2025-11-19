import BusAPI
import CoreLocation
import Foundation

struct BusRouteWithArrival: Identifiable {
    let id: String
    let route: BusRoute
    let arrival: BusArrival?

    init(route: BusRoute, arrival: BusArrival?) {
        id = route.id
        self.route = route
        self.arrival = arrival
    }
}

@MainActor
final class BusRouteSearchViewModel: ObservableObject {
    @Published var busRoutes: [BusRouteWithArrival] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let busRepository = MainBusRepository()
    let busStop: BusStop
    let recognizedText: String

    init(busStop: BusStop, recognizedText: String) {
        self.busStop = busStop
        self.recognizedText = recognizedText
    }

    func fetchBusRoutes() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                let cityCodeString = try await detectCityCode(from: CLLocationCoordinate2D(
                    latitude: busStop.latitude,
                    longitude: busStop.longitude
                ))

                let routes = try await busRepository.fetchRoutesPassingThroughStop(
                    cityCode: cityCodeString,
                    nodeId: busStop.nodeId
                )

                let arrivals = try await busRepository.fetchStopArrivals(
                    cityCode: cityCodeString,
                    nodeId: busStop.nodeId
                )

                busRoutes = routes.map { route in
                    let matchingArrival = arrivals.first { arrival in
                        arrival.routeId == route.routeId
                    }
                    return BusRouteWithArrival(route: route, arrival: matchingArrival)
                }
            } catch {
                print("Error fetching bus routes: \(error)")
                errorMessage = error.localizedDescription
                busRoutes = []
            }
        }
    }

    private func detectCityCode(from gps: CLLocationCoordinate2D) async throws -> String {
        let locationProvider = LocationManager()
        guard let placemark = try await locationProvider.fetchPlacemark(from: gps) else {
            throw BusAPIError.unknown("Failed to fetch placemark for city code detection.")
        }
        let detectedCityCode = CityCodeConverter.findCode(from: placemark) ?? "31020"
        return detectedCityCode
    }
}
