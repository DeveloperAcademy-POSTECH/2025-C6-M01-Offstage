import BusAPI
import CoreLocation
import Foundation

@MainActor
final class BusRouteSearchViewModel: ObservableObject {
    @Published var busRoutes: [BusRouteWithArrival] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let busRepository = MainBusRepository()
    let busStop: BusStop
    let recognizedText: String
    private var refreshTask: Task<Void, Never>?

    init(busStop: BusStop, recognizedText: String) {
        self.busStop = busStop
        self.recognizedText = recognizedText
    }

    deinit {
        refreshTask?.cancel()
    }

    func startAutoRefresh() {
        // 기존 작업이 있으면 취소
        refreshTask?.cancel()

        refreshTask = Task {
            // 초기 로드
            await fetchBusRoutes()

            // 30초마다 자동 새로고침
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: RefreshInterval.busArrival)
                } catch {
                    break
                }

                if Task.isCancelled { break }

                await fetchBusRoutes()
            }
        }
    }

    func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    func fetchBusRoutes() async {
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

    private func detectCityCode(from gps: CLLocationCoordinate2D) async throws -> String {
        let locationProvider = LocationManager()
        guard let placemark = try await locationProvider.fetchPlacemark(from: gps) else {
            throw BusAPIError.unknown("Failed to fetch placemark for city code detection.")
        }
        let detectedCityCode = CityCodeConverter.findCode(from: placemark) ?? "31020"
        return detectedCityCode
    }
}
