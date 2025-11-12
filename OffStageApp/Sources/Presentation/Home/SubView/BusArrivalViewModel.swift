import BusAPI
import Combine
import CoreLocation
import Foundation

@MainActor
final class BusArrivalViewModel: ObservableObject {
    @Published var busArrivalInfo: BusArrival?
    @Published var busLocationInfo: BusLocation?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isBusVisionButtonEnabled: Bool = false
    @Published var currentEstimatedArrivalTime: Int?

    let busStop: BusStop
    let busRoute: BusRoute
    private let busRepository: BusRepository
    private let locationProvider: LocationProviding
    private var timer: Timer?

    init(
        busStop: BusStop,
        busRoute: BusRoute,
        busRepository: BusRepository = MainBusRepository(),
        locationProvider: LocationProviding = LocationManager()
    ) {
        self.busStop = busStop
        self.busRoute = busRoute
        self.busRepository = busRepository
        self.locationProvider = locationProvider
    }

    func fetchArrivalInfo() {
        isLoading = true
        errorMessage = nil
        stopArrivalTimer()
        Task {
            defer { isLoading = false }
            do {
                let cityCodeString = try await detectCityCode(from: CLLocationCoordinate2D(
                    latitude: busStop.latitude,
                    longitude: busStop.longitude
                ))

                let arrivals = try await busRepository.fetchRouteArrivals(
                    cityCode: cityCodeString,
                    nodeId: busStop.nodeId,
                    routeId: busRoute.routeId
                )

                if let firstArrival = arrivals.first {
                    self.busArrivalInfo = firstArrival
                    self.currentEstimatedArrivalTime = firstArrival.estimatedArrivalTime
                    self.busLocationInfo = nil
                    startArrivalTimer()
                } else {
                    self.busArrivalInfo = nil
                    self.currentEstimatedArrivalTime = nil
                    let locations = try await busRepository.fetchRouteLocations(
                        cityCode: cityCodeString,
                        routeId: busRoute.routeId,
                        page: nil
                    )
                    if let firstLocation = locations.first {
                        self.busLocationInfo = firstLocation
                    } else {
                        self.errorMessage = "현재는 운행중인 노선이 없습니다."
                    }
                }
            } catch {
                self.errorMessage = "도착 정보를 불러오는 데 실패했습니다: \(error.localizedDescription)"
                print("Error fetching bus arrival info: \(error)")
            }
        }
    }

    private func startArrivalTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }

            if let estimatedTime = currentEstimatedArrivalTime, estimatedTime > 0 {
                currentEstimatedArrivalTime = estimatedTime - 1
            }

            if let estimatedTime = currentEstimatedArrivalTime, estimatedTime <= 60 {
                isBusVisionButtonEnabled = true
            } else {
                isBusVisionButtonEnabled = false
            }

            if let estimatedTime = currentEstimatedArrivalTime, estimatedTime <= 0, !self.isBusVisionButtonEnabled {
                stopArrivalTimer()
                fetchArrivalInfo()
            }
        }
    }

    func stopArrivalTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func detectCityCode(from gps: CLLocationCoordinate2D) async throws -> String {
        guard let placemark = try await locationProvider.fetchPlacemark(from: gps) else {
            throw BusAPIError.unknown("Failed to fetch placemark for city code detection.")
        }
        let detectedCityCode = CityCodeConverter.findCode(from: placemark) ?? "31020" // Default to Seongnam
        return detectedCityCode
    }
}
