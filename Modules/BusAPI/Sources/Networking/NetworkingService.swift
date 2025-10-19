import Foundation
import Logging
import Moya

public enum NetworkError: Error {
    case decodingError(error: Error, data: Data)
    case moyaError(Error)
}

public protocol NetworkingService {
    func request<T: Codable>(target: TargetType, responseType: T.Type) async throws -> (decoded: T, rawData: Data)
}

private final class ServiceKeyPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let url = request.url,
              let busTarget = target as? BusAPITarget
        else {
            return request
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        let serviceKeyString = "serviceKey=\(busTarget.serviceKey)"

        if let existingQuery = components.percentEncodedQuery {
            components.percentEncodedQuery = existingQuery + "&" + serviceKeyString
        } else {
            components.percentEncodedQuery = serviceKeyString
        }

        var mutableRequest = request
        mutableRequest.url = components.url

        logInfo("Final URL with service key: \(mutableRequest.url?.absoluteString ?? "nil")")

        return mutableRequest
    }
}

public final class NetworkingAPI: NetworkingService {
    public static let shared = NetworkingAPI()
    private let provider: MoyaProvider<MultiTarget>

    public init(isMocking: Bool = false) {
        let plugins: [PluginType] = isMocking ? [] : [ServiceKeyPlugin()]
        let stubClosure = { (_: MultiTarget) -> Moya.StubBehavior in
            return isMocking ? .immediate : .never
        }
        provider = MoyaProvider<MultiTarget>(stubClosure: stubClosure, plugins: plugins)
    }

    public func request<T: Codable>(
        target: TargetType,
        responseType _: T.Type
    ) async throws -> (decoded: T, rawData: Data) {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(MultiTarget(target)) { result in
                logInfo("Requesting API: \(target.path)")
                switch result {
                case let .success(response):
                    logDebug("Received response: \(response)")
                    do {
                        let decodedData = try JSONDecoder().decode(T.self, from: response.data)
                        continuation.resume(returning: (decodedData, response.data))
                    } catch {
                        logError("Decoding Error: \(error)")
                        continuation.resume(throwing: NetworkError.decodingError(error: error, data: response.data))
                    }
                case let .failure(error):
                    logError("Moya Error: \(error)")
                    continuation.resume(throwing: NetworkError.moyaError(error))
                }
            }
        }
    }
}
