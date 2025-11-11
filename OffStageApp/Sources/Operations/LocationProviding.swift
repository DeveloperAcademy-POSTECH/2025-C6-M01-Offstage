import Combine
import CoreLocation
import Foundation

/// An interface for a service that provides the user's current location.
///
/// This protocol is part of the Operations layer and defines a contract for location services
/// that the rest of the application can depend on.
public protocol LocationProviding {
    /// A publisher that emits the user's current location or an error.
    var currentLocation: AnyPublisher<CLLocationCoordinate2D, Error> { get }

    /// Requests permission from the user to access their location.
    func requestLocationPermission()

    /// GPS 좌표를 주소(CLPlacemark)로 변환합니다.
    func fetchPlacemark(from location: CLLocationCoordinate2D) async throws -> CLPlacemark?

    func requestLocation() async throws -> CLLocationCoordinate2D
}
