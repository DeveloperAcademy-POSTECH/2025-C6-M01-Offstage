@testable import BusAPI
import XCTest

final class BusAPITests: XCTestCase {
    private let sampleContext = (
        cityCode: "25",
        nodeId: "DJB8001793",
        routeId: "DJB30300002",
        routeNo: "2",
        gpsLati: 36.3325,
        gpsLong: 127.4342
    )

    private lazy var mockedNetworking = NetworkingAPI(isMocking: true)

    // MARK: - Mocked responses

    func testMockedArrivalsResponseDecodes() async throws {
        try await assertMockResponse(
            api: .getArrivals(cityCode: sampleContext.cityCode, nodeId: sampleContext.nodeId),
            decoding: BusArrivalInfo.self
        )
    }

    func testMockedArrivalsForRouteResponseDecodes() async throws {
        try await assertMockResponse(
            api: .getArrivalsForRoute(
                cityCode: sampleContext.cityCode,
                nodeId: sampleContext.nodeId,
                routeId: sampleContext.routeId
            ),
            decoding: BusArrivalInfo.self
        )
    }

    func testMockedRouteBusLocationsResponseDecodes() async throws {
        try await assertMockResponse(
            api: .getRouteBusLocations(cityCode: sampleContext.cityCode, routeId: sampleContext.routeId),
            decoding: BusLocation.self
        )
    }

    func testMockedSearchStopResponseDecodes() async throws {
        try await assertMockResponse(
            api: .searchStop(cityCode: sampleContext.cityCode, stopName: "Sample"),
            decoding: BusStop.self
        )
    }

    func testMockedStopsByGpsResponseDecodes() async throws {
        try await assertMockResponse(
            api: .getStopsByGps(gpsLati: sampleContext.gpsLati, gpsLong: sampleContext.gpsLong),
            decoding: BusStop.self
        )
    }

    func testMockedStopRoutesResponseDecodes() async throws {
        try await assertMockResponse(
            api: .getStopRoutes(cityCode: sampleContext.cityCode, nodeId: sampleContext.nodeId),
            decoding: StationRoute.self
        )
    }

    func testMockedRouteInfoResponseDecodes() async throws {
        try await assertMockResponse(
            api: .getRouteInfo(cityCode: sampleContext.cityCode, routeId: sampleContext.routeId),
            decoding: BusRoute.self
        )
    }

    func testMockedSearchRouteResponseDecodes() async throws {
        try await assertMockResponse(
            api: .searchRoute(cityCode: sampleContext.cityCode, routeNo: sampleContext.routeNo),
            decoding: BusRoute.self
        )
    }

    func testMockedRouteStopsResponseDecodes() async throws {
        try await assertMockResponse(
            api: .getRouteStops(cityCode: sampleContext.cityCode, routeId: sampleContext.routeId),
            decoding: BusStop.self
        )
    }

    func testBusStopInfoCodableRoundTrip() throws {
        let info = BusStopInfo(
            cityCode: 25,
            nodeId: "NODE",
            routeId: "ROUTE",
            stopName: "Sample Stop",
            routeNo: "100",
            gpsLati: 37.1234,
            gpsLong: 127.5678
        )

        let data = try JSONEncoder().encode(info)
        let decoded = try JSONDecoder().decode(BusStopInfo.self, from: data)

        XCTAssertEqual(decoded, info)
    }

    // MARK: - Live networking

    func testNetworkingWithoutMockingFailsWithoutValidServiceKey() async {
        let networking = NetworkingAPI(isMocking: false)
        do {
            let _: ApiResponse<ItemBody<BusArrivalInfo>> = try await networking.request(
                api: .getArrivals(cityCode: sampleContext.cityCode, nodeId: sampleContext.nodeId)
            )
            XCTFail("Expected request to fail without a valid service key")
        } catch NetworkError.moyaError {
            // Expected due to missing/invalid credentials or network restrictions.
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Helpers

    private func assertMockResponse<T: Codable>(
        api: BusAPI,
        decoding _: T.Type,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        let response: ApiResponse<ItemBody<T>> = try await mockedNetworking.request(api: api)
        XCTAssertEqual(response.response.header.resultCode, "00", file: file, line: line)
        let items = response.response.body?.items.item ?? []
        XCTAssertFalse(items.isEmpty, "Expected at least one item for \(api)", file: file, line: line)
    }
}
