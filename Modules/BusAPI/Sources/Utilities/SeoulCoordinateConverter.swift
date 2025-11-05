import Foundation

/// Utility to convert WGS84 (latitude, longitude) to Seoul TM coordinates (tmX, tmY).
/// NOTE: The Seoul API expects TM coordinates. The conversion below is a placeholder
/// implementation that should be replaced with a more accurate TM conversion (EPSG:5179/2097)
/// when precise results are required.
public enum SeoulCoordinateConverter {
    /// Convert WGS84 degrees to a naive TM-like coordinate.
    /// - Parameters:
    ///   - latitude: latitude in degrees
    ///   - longitude: longitude in degrees
    /// - Returns: (tmX, tmY) pair as Doubles
    public static func wgs84ToTM(latitude: Double, longitude: Double) -> (Double, Double) {
        // Simple approximate conversion used as a placeholder.
        // TODO: Replace with a proper projection (e.g., Korean TM / EPSG:5179) implementation.
        // This naive mapping multiplies degrees to produce values roughly on the same scale
        // as TM coordinates so the API can respond; accuracy is not guaranteed.
        let tmX = longitude * 100_000.0
        let tmY = latitude * 100_000.0
        return (tmX, tmY)
    }
}
