import Combine
import CoreLocation
import Foundation

/// A concrete implementation of the `LocationProviding` protocol using Apple's CoreLocation framework.
///
/// This class is part of the Infrastructure layer and is responsible for all interactions
/// with the `CLLocationManager` system API.
final class LocationManager: NSObject, LocationProviding {
    private let locationManager = CLLocationManager()
    private let subject = PassthroughSubject<LocationCoordinate, Error>()

    lazy var currentLocation: AnyPublisher<LocationCoordinate, Error> = subject.eraseToAnyPublisher()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
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
        let coordinate = LocationCoordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        subject.send(coordinate)
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        subject.send(completion: .failure(error))
    }
}
