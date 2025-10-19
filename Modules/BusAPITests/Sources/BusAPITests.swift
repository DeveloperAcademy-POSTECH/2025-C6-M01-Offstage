@testable import BusAPI
import Moya
import XCTest

final class BusAPITests: XCTestCase {
    private let sampleContext = (
        cityCode: "25",
        nodeId: "DJB8001793",
        routeId: "DJB30300002",
        routeNo: "2",
        stopName: "대전역",
        gpsLati: 36.3325,
        gpsLong: 127.4342
    )

    private let networking = NetworkingAPI()

    // MARK: - Live networking Tests

    func testLiveArrivalsResponseDecodes() async throws {
        try await assertLiveResponse(
            target: ArrivalEndpoint.getArrivals(cityCode: sampleContext.cityCode, nodeId: sampleContext.nodeId),
            decoding: BusArrivalInfo.self
        )
    }

    func testLiveArrivalsForRouteResponseDecodes() async throws {
        try await assertLiveResponse(
            target: ArrivalEndpoint.getArrivalsForRoute(
                cityCode: sampleContext.cityCode,
                nodeId: sampleContext.nodeId,
                routeId: sampleContext.routeId
            ),
            decoding: BusArrivalInfo.self
        )
    }

    func testLiveRouteBusLocationsResponseDecodes() async throws {
        try await assertLiveResponse(
            target: LocationEndpoint.getRouteBusLocations(
                cityCode: sampleContext.cityCode,
                routeId: sampleContext.routeId
            ),
            decoding: BusLocation.self
        )
    }

    func testLiveSearchStopResponseDecodes() async throws {
        try await assertLiveResponse(
            target: StopEndpoint.searchStop(cityCode: sampleContext.cityCode, stopName: sampleContext.stopName),
            decoding: BusStop.self
        )
    }

    func testLiveStopsByGpsResponseDecodes() async throws {
        try await assertLiveResponse(
            target: StopEndpoint.getStopsByGps(gpsLati: sampleContext.gpsLati, gpsLong: sampleContext.gpsLong),
            decoding: BusStop.self
        )
    }

    func testLiveStopRoutesResponseDecodes() async throws {
        try await assertLiveResponse(
            target: StopEndpoint.getStopRoutes(cityCode: sampleContext.cityCode, nodeId: sampleContext.nodeId),
            decoding: StationRoute.self
        )
    }

    func testLiveRouteInfoResponseDecodes() async throws {
        try await assertLiveResponse(
            target: RouteEndpoint.getRouteInfo(cityCode: sampleContext.cityCode, routeId: sampleContext.routeId),
            decoding: BusRoute.self
        )
    }

    func testLiveSearchRouteResponseDecodes() async throws {
        try await assertLiveResponse(
            target: RouteEndpoint.searchRoute(cityCode: sampleContext.cityCode, routeNo: sampleContext.routeNo),
            decoding: BusRoute.self
        )
    }

    func testLiveRouteStopsResponseDecodes() async throws {
        try await assertLiveResponse(
            target: RouteEndpoint.getRouteStops(cityCode: sampleContext.cityCode, routeId: sampleContext.routeId),
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

    // MARK: - Helpers

    private func assertLiveResponse<T: Codable>(
        target: TargetType,
        decoding _: T.Type,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        let (response, rawData): (ApiResponse<ItemBody<T>>, Data) = try await networking.request(
            target: target,
            responseType: ApiResponse<ItemBody<T>>.self
        )

        if let rawString = String(data: rawData, encoding: .utf8) {
            print("Raw response for \(target.path):\n\(rawString)\n")
        }

        XCTAssertEqual(
            response.response.header.resultCode,
            "00",
            "API request for \(target.path) failed with message: \(response.response.header.resultMsg)",
            file: file,
            line: line
        )
    }
}
