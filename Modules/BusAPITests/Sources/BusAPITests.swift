@testable import BusAPI
import Moya
import XCTest

final class BusAPITests: XCTestCase {
    private let provider = MoyaProvider<CityCodeTarget>(
        plugins: [
            ServiceKeyPlugin(),
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
        ]
    )
    private let decoder = JSONDecoder()

    func testFetchCityCodeList() async throws {
        let data = try await request(.cityCodeList)

        if let rawString = String(data: data, encoding: .utf8) {
            print("Received body:\n\(rawString)")
        } else {
            print("Received body is not valid UTF-8, size: \(data.count) bytes")
        }

        let cityCodes = try decoder.decode(CityCodeListResponse.self, from: data)

        XCTAssertEqual(cityCodes.response.header.resultCode, "00")
        XCTAssertFalse(cityCodes.response.body.items.item.isEmpty)
    }

    private func request(_ target: CityCodeTarget) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case let .success(response):
                    continuation.resume(returning: response.data)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

private enum CityCodeTarget: BusAPITarget {
    case cityCodeList

    var baseURL: URL { URL(string: "https://apis.data.go.kr/1613000")! }

    var path: String {
        switch self {
        case .cityCodeList:
            "/BusSttnInfoInqireService/getCtyCodeList"
        }
    }

    var method: Moya.Method { .get }
    var sampleData: Data { Data() }

    var task: Moya.Task {
        let parameters: [String: Any] = [
            "_type": "json",
        ]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }

    var serviceKey: String { APIKeyProvider.stopServiceKey }
}

private struct CityCodeListResponse: Decodable {
    let response: Response

    struct Response: Decodable {
        let header: Header
        let body: Body
    }

    struct Header: Decodable {
        let resultCode: String
        let resultMsg: String
    }

    struct Body: Decodable {
        let items: Items
    }

    struct Items: Decodable {
        let item: [City]
    }

    struct City: Decodable {
        let citycode: Int
        let cityname: String
    }
}
