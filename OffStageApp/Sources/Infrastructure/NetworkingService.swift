import Foundation
import Moya

protocol NetworkingService {
    func request<T: Codable>(api: BusAPI) async throws -> T
}

final class NetworkingAPI: NetworkingService {
    private let provider: MoyaProvider<BusAPI>

    init(provider: MoyaProvider<BusAPI> = MoyaProvider<BusAPI>()) {
        self.provider = provider
    }

    func request<T: Codable>(api: BusAPI) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(api) { result in
                switch result {
                case let .success(response):
                    do {
                        let decodedData = try JSONDecoder().decode(T.self, from: response.data)
                        continuation.resume(returning: decodedData)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
