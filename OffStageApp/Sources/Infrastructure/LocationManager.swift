import Combine
import CoreLocation
import Foundation
import MapKit

/// A concrete implementation of the `LocationProviding` protocol using Apple's CoreLocation framework.
///
/// This class is part of the Infrastructure layer and is responsible for all interactions
/// with the `CLLocationManager` system API.
final class LocationManager: NSObject, LocationProviding {
    static let shared = LocationManager()

    private let locationManager = CLLocationManager()
    private let subject = PassthroughSubject<CLLocationCoordinate2D, Error>()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    lazy var currentLocation: AnyPublisher<CLLocationCoordinate2D, Error> = subject.eraseToAnyPublisher()

    // [추가] Reverse Geocoding을 위한 지오코더
    private let geocoder = CLGeocoder()

    #if DEBUG_MODE
        // 디버그 모드에서 강제 위치 설정
        var overrideLocation: CLLocationCoordinate2D?
        var isOverrideEnabled: Bool = false
    #endif

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = true
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    func startBackgroundLocationUpdates() {
        locationManager.startUpdatingLocation()
    }

    func stopBackgroundLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }

    func requestLocation() async throws -> CLLocationCoordinate2D {
        #if DEBUG_MODE
            if isOverrideEnabled, let overrideLocation {
                return overrideLocation
            }

            if shouldUseMockData {
                return mockC5Location
            }
        #endif

        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    #if DEBUG_MODE
        private var shouldUseMockData: Bool {
            UserDefaults.standard.bool(forKey: "useMockData")
        }

        private var mockC5Location: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: 36.0143, longitude: 129.3256)
        }
    #endif

    func fetchPlacemark(from location: CLLocationCoordinate2D) async throws -> CLPlacemark? {
        #if DEBUG_MODE
            if shouldUseMockData {
                return mockC5Placemark(for: location)
            }
        #endif

        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let placemarks = try await geocoder.reverseGeocodeLocation(
            clLocation,
            preferredLocale: Locale(identifier: "ko-KR")
        )
        return placemarks.first
    }

    #if DEBUG_MODE
        private func mockC5Placemark(for location: CLLocationCoordinate2D) -> CLPlacemark {
            MKPlacemark(coordinate: location, addressDictionary: [
                "City": "포항시",
                "State": "경상북도",
            ])
        }
    #endif
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // locationManager.startUpdatingLocation() // requestLocation()을 위해 자동 시작 제거
            break
        case .denied, .restricted:
            // TODO: Handle location access denial. Maybe publish an error.
            break
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        #if DEBUG_MODE
            if isOverrideEnabled, let overrideLocation {
                subject.send(overrideLocation)
                locationContinuation?.resume(returning: overrideLocation)
                locationContinuation = nil
                return
            }
        #endif

        guard let location = locations.last else { return }
        let coordinate = CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        subject.send(coordinate)
        locationContinuation?.resume(returning: coordinate)
        locationContinuation = nil
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        subject.send(completion: .failure(error))
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}
