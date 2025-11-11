import Foundation
import Moya

/// Errors thrown by the Bus API module.
public enum BusAPIError: Error {
    /// Thrown when the required service key for a target has not been configured.
    case missingServiceKey(BusAPIService)
    /// Thrown when a required parameter is missing.
    case missingParameter(name: String)
    /// Thrown when the API responds with a non-success status header.
    case invalidStatus(header: BusAPIHeader)
    /// Thrown when the API responds without a body or items payload.
    case emptyBody
    /// Thrown when a successful API call returns no results.
    case noResults
    /// Thrown when decoding the response payload fails.
    case decodingFailed(Error)
    /// Thrown when the underlying Moya request fails.
    case network(MoyaError)
    /// Thrown for unknown or unhandled errors.
    case unknown(String)
}

extension BusAPIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .missingServiceKey(service):
            "Missing service key for \(service.infoPlistKey)."
        case let .missingParameter(name):
            "Missing required parameter: \(name)"
        case let .invalidStatus(header):
            "Bus API returned error code \(header.resultCode): \(header.resultMessage)"
        case .emptyBody:
            "Bus API returned an empty body."
        case .noResults:
            "The API request was successful, but returned no results."
        case let .decodingFailed(error):
            "Failed to decode Bus API response: \(error.localizedDescription)"
        case let .network(error):
            "Bus API network request failed: \(error.localizedDescription)"
        case let .unknown(message):
            "An unknown Bus API error occurred: \(message)"
        }
    }
}
