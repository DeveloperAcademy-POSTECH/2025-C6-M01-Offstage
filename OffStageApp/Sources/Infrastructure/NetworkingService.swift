import Foundation
import Moya

enum NetworkError: Error {
    case decodingError(error: Error, data: Data)
    case moyaError(Error)
}

protocol NetworkingService {
    func request<T: Codable>(api: BusAPI) async throws -> T
}

final class NetworkingAPI: NetworkingService {
    private let provider: MoyaProvider<BusAPI>

    init(isMocking: Bool = true) {
        provider = MoyaProvider<BusAPI>(stubClosure: isMocking ? MoyaProvider.immediatelyStub : MoyaProvider.neverStub)
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
                        continuation.resume(throwing: NetworkError.decodingError(error: error, data: response.data))
                    }
                case let .failure(error):
                    continuation.resume(throwing: NetworkError.moyaError(error))
                }
            }
        }
    }
}
