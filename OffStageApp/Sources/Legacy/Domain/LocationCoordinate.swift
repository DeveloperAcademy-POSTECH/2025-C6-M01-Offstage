import Foundation

/// A structure to represent a geographical coordinate.
///
/// This model is part of the Domain layer and is independent of any specific mapping or location framework.
public struct LocationCoordinate: Equatable {
    /// The latitude in degrees.
    public let latitude: Double

    /// The longitude in degrees.
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
