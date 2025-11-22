import Combine
import CoreLocation
import Foundation

import BusAPI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var nearestBusStop: BusStop?
    @Published var busRoutes: [BusRoute] = []
    @Published var isLoading = false

    private var locationProvider: LocationProviding
    private let busRepository = MainBusRepository()

    init(locationProvider: LocationProviding = LocationManager()) {
        self.locationProvider = locationProvider
    }

    private func detectCityCode(from gps: CLLocationCoordinate2D) async throws -> String {
        guard let placemark = try await locationProvider.fetchPlacemark(from: gps) else {
            throw BusAPIError.unknown("Failed to fetch placemark for city code detection.")
        }
        let detectedCityCode = CityCodeConverter.findCode(from: placemark) ?? "31020" // Default to Seongnam
        return detectedCityCode
    }

    func fetchNearestStop() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                // 먼저 백그라운드에서 저장된 위치를 확인
                var coordinate: CLLocationCoordinate2D

                if let cachedLocation = BackgroundLocationManager.getLastKnownLocation() {
                    print("✅ Using cached location from background tracking")
                    coordinate = cachedLocation
                } else {
                    print("📍 Requesting fresh location")
                    let location = try await locationProvider.requestLocation()
                    coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                }

                let cityCodeString = try await detectCityCode(from: coordinate)
                let stops = try await busRepository.fetchStopsNearby(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    cityCode: cityCodeString
                )

                if let firstStop = stops.first {
                    nearestBusStop = firstStop
                    await fetchBusRoutes(for: firstStop)
                } else {
                    nearestBusStop = nil
                    busRoutes = []
                }

            } catch {
                // TODO: Handle error properly
                print("Error fetching nearest stop: \(error)")
                nearestBusStop = nil
                busRoutes = []
            }
        }
    }

    private func fetchBusRoutes(for stop: BusStop) async {
        do {
            let cityCodeString = try await detectCityCode(from: CLLocationCoordinate2D(
                latitude: stop.latitude,
                longitude: stop.longitude
            ))
            let routes = try await busRepository.fetchRoutesPassingThroughStop(
                cityCode: cityCodeString,
                nodeId: stop.nodeId
            )
            busRoutes = routes
        } catch {
            print("Error fetching bus routes: \(error)")
            busRoutes = []
        }
    }
}
