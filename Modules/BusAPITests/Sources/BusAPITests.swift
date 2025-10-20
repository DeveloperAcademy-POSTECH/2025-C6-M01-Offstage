@testable import BusAPI
import Moya
import XCTest

final class BusAPITests: XCTestCase {
    private let plugins: [PluginType] = [
        ServiceKeyPlugin(),
        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
    ]
    private var decoder: JSONDecoder!

    override func setUpWithError() throws {
        try super.setUpWithError()
        decoder = JSONDecoder()
    }

    override func tearDownWithError() throws {
        decoder = nil
        try super.tearDownWithError()
    }

    func test_Location_노선별버스위치_페이지() async throws {
        let header = try await requestHeader(
            LocationRouteListPagedTarget(
                cityCode: Fixture.cityCode,
                routeId: Fixture.routeId,
                pageNo: 1,
                numOfRows: 10
            ),
            attachmentName: #function
        )
        XCTAssertEqual(header.resultCode, "00")
        XCTAssertFalse(header.resultMsg.isEmpty)
    }

    func test_Location_노선별버스위치_간단() async throws {
        let header = try await requestHeader(
            LocationEndpoint.getRouteBusLocations(
                cityCode: Fixture.cityCode,
                routeId: Fixture.routeId
            ),
            attachmentName: #function
        )
        XCTAssertEqual(header.resultCode, "00")
        XCTAssertFalse(header.resultMsg.isEmpty)
    }

    func test_Stop_도시코드목록() async throws {
        let header = try await requestHeader(
            StopCityCodeListTarget(),
            attachmentName: #function
        )
        XCTAssertEqual(header.resultCode, "00")
        XCTAssertFalse(header.resultMsg.isEmpty)
    }

    func test_Stop_이름번호로정류소목록() async throws {
        let header = try await requestHeader(
            StopEndpoint.searchStop(
                cityCode: Fixture.cityCode,
                stopName: Fixture.nodeName
            ),
            attachmentName: #function
        )
        XCTAssertEqual(header.resultCode, "00")
        XCTAssertFalse(header.resultMsg.isEmpty)
    }

    func test_Stop_좌표기준정류소() async throws {
        let header = try await requestHeader(
            StopEndpoint.getStopsByGps(
                gpsLati: Fixture.gpsLatitude,
                gpsLong: Fixture.gpsLongitude
            ),
            attachmentName: #function
        )
        XCTAssertEqual(header.resultCode, "00")
        XCTAssertFalse(header.resultMsg.isEmpty)
    }

    func test_Stop_정류소경유노선목록() async throws {
        let header = try await requestHeader(
            StopEndpoint.getStopRoutes(
                cityCode: Fixture.cityCode,
                nodeId: Fixture.nodeId
            ),
            attachmentName: #function
        )
        XCTAssertEqual(header.resultCode, "00")
        XCTAssertFalse(header.resultMsg.isEmpty)
    }

    func test_Route_노선기본정보() async throws {
        let header = try await requestHeader(
            RouteEndpoint.getRouteInfo(
                cityCode: Fixture.cityCode,
                routeId: Fixture.routeId
            ),
            attachmentName: #function
        )
        XCTAssertEqual(header.resultCode, "00")
        XCTAssertFalse(header.resultMsg.isEmpty)
    }

    func test_Route_노선번호검색() async throws {
        let header = try await requestHeader(
            RouteEndpoint.searchRoute(
                cityCode: Fixture.cityCode,
                routeNo: Fixture.routeNo
            ),
            attachmentName: #function
        )
        XCTAssertEqual(header.resultCode, "00")
        XCTAssertFalse(header.resultMsg.isEmpty)
    }

    func test_Route_노선통과정류장() async throws {
        let header = try await requestHeader(
            RouteEndpoint.getRouteStops(
                cityCode: Fixture.cityCode,
                routeId: Fixture.routeId
            ),
            attachmentName: #function
        )
        XCTAssertEqual(header.resultCode, "00")
        XCTAssertFalse(header.resultMsg.isEmpty)
    }

    func test_Arrival_도시코드목록() async throws {
        let header = try await requestHeader(
            ArrivalCityCodeListTarget(),
            attachmentName: #function
        )
        XCTAssertEqual(header.resultCode, "00")
        XCTAssertFalse(header.resultMsg.isEmpty)
    }

    func test_Arrival_정류소전체도착정보() async throws {
        let header = try await requestHeader(
            ArrivalEndpoint.getArrivals(
                cityCode: Fixture.cityCode,
                nodeId: Fixture.nodeId
            ),
            attachmentName: #function
        )
        XCTAssertEqual(header.resultCode, "00")
        XCTAssertFalse(header.resultMsg.isEmpty)
    }

    func test_Arrival_특정노선도착정보() async throws {
        let header = try await requestHeader(
            ArrivalEndpoint.getArrivalsForRoute(
                cityCode: Fixture.cityCode,
                nodeId: Fixture.nodeId,
                routeId: Fixture.routeId
            ),
            attachmentName: #function
        )
        XCTAssertEqual(header.resultCode, "00")
        XCTAssertFalse(header.resultMsg.isEmpty)
    }

    private func requestHeader(
        _ target: some BusAPITarget,
        attachmentName: String
    ) async throws -> APIEnvelope.Header {
        let data = try await executeRequest(target)
        attachResponse(data, name: attachmentName)
        let envelope = try decoder.decode(APIEnvelope.self, from: data)
        return envelope.response.header
    }

    private func executeRequest<T: BusAPITarget>(_ target: T) async throws -> Data {
        let provider = MoyaProvider<T>(plugins: plugins)
        return try await withCheckedThrowingContinuation { continuation in
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

    private func attachResponse(_ data: Data, name: String) {
        guard let rawString = String(data: data, encoding: .utf8) else { return }
        let attachment = XCTAttachment(string: rawString)
        attachment.name = name
        attachment.lifetime = .deleteOnSuccess
        add(attachment)
    }
}

private enum Fixture {
    static let cityCode = "25"
    static let nodeId = "DJB8001793"
    static let routeId = "DJB30300050"
    static let nodeName = "강남"
    static let routeNo = "102"
    static let gpsLatitude = 35.538377
    static let gpsLongitude = 129.31136
}

private struct APIEnvelope: Decodable {
    let response: Response

    struct Response: Decodable {
        let header: Header
    }

    struct Header: Decodable {
        let resultCode: String
        let resultMsg: String
    }
}

private struct LocationRouteListPagedTarget: BusAPITarget {
    let cityCode: String
    let routeId: String
    let pageNo: Int
    let numOfRows: Int

    var path: String {
        "/BusLcInfoInqireService/getRouteAcctoBusLcList"
    }

    var task: Moya.Task {
        let parameters: [String: Any] = [
            "cityCode": cityCode,
            "routeId": routeId,
            "pageNo": pageNo,
            "numOfRows": numOfRows,
            "_type": "json",
        ]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
    }

    var serviceKey: String {
        APIKeyProvider.locationServiceKey
    }
}

private struct StopCityCodeListTarget: BusAPITarget {
    var path: String {
        "/BusSttnInfoInqireService/getCtyCodeList"
    }

    var task: Moya.Task {
        let parameters: [String: Any] = [
            "_type": "json",
        ]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
    }

    var serviceKey: String {
        APIKeyProvider.stopServiceKey
    }
}

private struct ArrivalCityCodeListTarget: BusAPITarget {
    var path: String {
        "/ArvlInfoInqireService/getCtyCodeList"
    }

    var task: Moya.Task {
        let parameters: [String: Any] = [
            "_type": "json",
        ]
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
    }

    var serviceKey: String {
        APIKeyProvider.arrivalServiceKey
    }
}
