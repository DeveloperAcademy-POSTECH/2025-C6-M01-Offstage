@testable import BusAPI
import Moya
import XCTest

final class BusAPITests: XCTestCase {
    private var repository: DefaultBusRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let plugins: [PluginType] = [
            ServiceKeyPlugin(),
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
        ]
        let provider = MoyaProvider<BusAPITarget>(plugins: plugins)
        repository = DefaultBusRepository(provider: provider)
    }

    override func tearDownWithError() throws {
        repository = nil
        try super.tearDownWithError()
    }

    func testFetchStopCities() async throws {
        try requireKeys(.stop)
        let cities = try await repository.fetchCities(for: .stop)
        XCTAssertFalse(cities.isEmpty)
        attachSummary(of: cities, name: #function)
    }

    func testFetchRouteLocations() async throws {
        try requireKeys(.location)
        let locations = try await repository.fetchRouteLocations(
            cityCode: Fixture.cityCode,
            routeId: Fixture.routeId,
            page: 1
        )
        XCTAssertFalse(locations.isEmpty)
        attachSummary(of: locations, name: #function)
    }

    func testSearchStops() async throws {
        try requireKeys(.stop)
        let stops = try await repository.searchStops(
            cityCode: Fixture.cityCode,
            keyword: Fixture.nodeName
        )
        XCTAssertFalse(stops.isEmpty)
        attachSummary(of: stops, name: #function)
    }

    func testFetchRouteInfo() async throws {
        try requireKeys(.route)
        let route = try await repository.fetchRouteInfo(
            cityCode: Fixture.cityCode,
            routeId: Fixture.routeId
        )
        XCTAssertNotNil(route)
        attachSummary(of: [route].compactMap { $0 }, name: #function)
    }

    func testFetchRouteStations() async throws {
        try requireKeys(.route)
        let stations = try await repository.fetchRouteStations(
            cityCode: Fixture.cityCode,
            routeId: Fixture.routeId
        )
        XCTAssertFalse(stations.isEmpty)
        attachSummary(of: stations, name: #function)
    }

    func testFetchStopArrivals() async throws {
        try requireKeys(.arrival)
        let arrivals = try await repository.fetchStopArrivals(
            cityCode: Fixture.cityCode,
            nodeId: Fixture.nodeId
        )
        XCTAssertFalse(arrivals.isEmpty)
        attachSummary(of: arrivals, name: #function)
    }

    func testFetchRouteArrivals() async throws {
        try requireKeys(.arrival)
        let arrivals = try await repository.fetchRouteArrivals(
            cityCode: Fixture.cityCode,
            nodeId: Fixture.nodeId,
            routeId: Fixture.routeId
        )
        XCTAssertFalse(arrivals.isEmpty)
        attachSummary(of: arrivals, name: #function)
    }

    private func requireKeys(
        _ services: BusAPIService...,
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) throws {
        let missing = services.filter { !BusAPIKey.isConfigured(for: $0) }
        guard missing.isEmpty else {
            let description = missing.map(\.infoPlistKey).joined(separator: ", ")
            throw XCTSkip("Missing Bus API keys: \(description)")
        }
    }

    private func attachSummary(of items: [some Any], name: String) {
        let summary = "\(name): count=\(items.count)"
        let attachment = XCTAttachment(string: summary)
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
}
