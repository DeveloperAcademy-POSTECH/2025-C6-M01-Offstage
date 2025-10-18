import Combine
import Foundation

/// An interface for a service that provides the user's current location.
///
/// This protocol is part of the Operations layer and defines a contract for location services
/// that the rest of the application can depend on.
public protocol LocationProviding {
    /// A publisher that emits the user's current location or an error.
    var currentLocation: AnyPublisher<LocationCoordinate, Error> { get }

    /// Requests permission from the user to access their location.
    func requestLocationPermission()
}
