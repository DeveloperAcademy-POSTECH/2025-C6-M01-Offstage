import BusAPI
import CoreLocation
import Foundation

@MainActor
final class BusRouteSearchViewModel: ObservableObject {
    @Published var busRoutes: [BusRoute] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let busRepository = MainBusRepository()
    private let busStop: BusStop
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
                busRoutes = routes
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
