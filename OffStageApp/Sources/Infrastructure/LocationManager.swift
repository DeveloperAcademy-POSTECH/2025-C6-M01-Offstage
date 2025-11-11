import Combine
import CoreLocation
import Foundation

/// A concrete implementation of the `LocationProviding` protocol using Apple's CoreLocation framework.
///
/// This class is part of the Infrastructure layer and is responsible for all interactions
/// with the `CLLocationManager` system API.
final class LocationManager: NSObject, LocationProviding {
    private let locationManager = CLLocationManager()
    private let subject = PassthroughSubject<CLLocationCoordinate2D, Error>()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    lazy var currentLocation: AnyPublisher<CLLocationCoordinate2D, Error> = subject.eraseToAnyPublisher()

    // [추가] Reverse Geocoding을 위한 지오코더
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestLocation() async throws -> CLLocationCoordinate2D {
        try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    // [추가] 프로토콜 함수 구현
    func fetchPlacemark(from location: CLLocationCoordinate2D) async throws -> CLPlacemark? {
        let clLocation = CLLocation(
            latitude: location.latitude,
            longitude: location.longitude
        )

        // 로케일을 "ko-KR"로 설정하여 주소를 한국어로 받습니다.
        let placemarks = try await geocoder.reverseGeocodeLocation(
            clLocation,
            preferredLocale: Locale(identifier: "ko-KR")
        )
        return placemarks.first
    }
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
