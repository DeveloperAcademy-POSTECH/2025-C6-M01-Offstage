import Foundation
import Testing

/// 최신 Postman 컬렉션과 동일한 파라미터를 사용해 각 엔드포인트를 직접 호출합니다.
struct BusApiTest {
    private let baseScenario = (
        cityCode: "25",
        nodeId: "DJB8001793",
        routeId: "DJB30300050",
        routeNo: "102",
        nodeName: "강남",
        nodeNo: "44810",
        latitude: "35.538377",
        longitude: "129.31136"
    )

    private let serviceKey = ""
    private func makeClient() -> BusAPIClient {
        BusAPIClient(serviceKey: serviceKey)
    }

    private func fetchRawData(
        service: String,
        method: String,
        queries: [URLQueryItem]
    ) async throws -> Data {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "apis.data.go.kr"
        components.path = "/1613000/\(service)/\(method)"
        components.queryItems = queries + [
            URLQueryItem(name: "serviceKey", value: serviceKey),
            URLQueryItem(name: "_type", value: "json"),
        ]
        let url = components.url!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }

    // MARK: - City codes

    @Test func arrivalCityCodes_decodesItems() async throws {
        let client = makeClient()
        let (envelope, url) = try await client.request(ArrivalCityCodeListRequest(pageNo: 1, numOfRows: 500))
        print("[arrival-city] URL=\(url)")
        #expect(envelope.response.header.resultCode == "00")
        let items = envelope.response.body?.items?.item ?? []
        #expect(items.contains { $0.citycode == baseScenario.cityCode })
    }

    @Test func stationCityCodes_decodesItems() async throws {
        let client = makeClient()
        let (envelope, url) = try await client.request(StationCityCodeListRequest(pageNo: 1, numOfRows: 500))
        print("[station-city] URL=\(url)")
        #expect(envelope.response.header.resultCode == "00")
        let items = envelope.response.body?.items?.item ?? []
        #expect(items.contains { $0.citycode == baseScenario.cityCode })
    }

    // MARK: - Stops

    @Test func stationList_decodesItems() async throws {
        let client = makeClient()
        let (envelope, url) = try await client.request(
            StationListRequest(
                cityCode: baseScenario.cityCode,
                nodeName: baseScenario.nodeName,
                nodeNumber: baseScenario.nodeNo,
                pageNo: 1,
                numOfRows: 10
            )
        )
        print("[station-list] URL=\(url)")
        #expect(envelope.response.header.resultCode == "00")
        let items = envelope.response.body?.items?.item ?? []
        let matched = items.first { $0.nodeid == baseScenario.nodeId || $0.nodeno == baseScenario.nodeNo }
        #expect(matched != nil)
    }

    @Test func stationNearby_decodesItems() async throws {
        let client = makeClient()
        let (envelope, url) = try await client.request(
            StationsByLocationRequest(
                latitude: baseScenario.latitude,
                longitude: baseScenario.longitude
            )
        )
        print("[station-nearby] URL=\(url)")
        #expect(envelope.response.header.resultCode == "00")
        let items = envelope.response.body?.items?.item ?? []
        #expect(!items.isEmpty)
    }

    @Test func stationRoutes_decodesItems() async throws {
        let client = makeClient()
        let (envelope, url) = try await client.request(
            RouteByStationRequest(
                cityCode: baseScenario.cityCode,
                nodeId: baseScenario.nodeId
            )
        )
        print("[station-routes] URL=\(url)")
        #expect(envelope.response.header.resultCode == "00")
        let items = envelope.response.body?.items?.item ?? []
        let matched = items.first { $0.routeid == baseScenario.routeId || $0.routeno == baseScenario.routeNo }
        #expect(matched != nil)
    }

    // MARK: - Arrival

    @Test func arrivalInfoRaw_printsResponse() async throws {
        let data = try await fetchRawData(
            service: "ArvlInfoInqireService",
            method: "getSttnAcctoArvlPrearngeInfoList",
            queries: [
                URLQueryItem(name: "cityCode", value: baseScenario.cityCode),
                URLQueryItem(name: "nodeId", value: baseScenario.nodeId),
                URLQueryItem(name: "pageNo", value: "1"),
                URLQueryItem(name: "numOfRows", value: "10"),
            ]
        )
        if let raw = String(data: data, encoding: .utf8) {
            print("arrival raw:\n\(raw)")
        }
    }

    @Test func arrivalInfo_decodesItems() async throws {
        let client = makeClient()
        let (envelope, url) = try await client.request(
            ArrivalInfoByStopRequest(
                cityCode: baseScenario.cityCode,
                nodeId: baseScenario.nodeId,
                pageNo: 1,
                numOfRows: 10
            )
        )
        print("[arrival-all] URL=\(url)")
        #expect(envelope.response.header.resultCode == "00")
        let items = envelope.response.body?.items?.item ?? []
        if let first = items.first {
            print("arrival sample -> \(first.debugSummary)")
        }
        #expect(items.count >= 0)
    }

    @Test func arrivalSpecificRoute_usesRouteFromList() async throws {
        let client = makeClient()
        let arrivals = try await fetchArrivalsList(client: client)
        let routeId = arrivals.first?.routeid ?? baseScenario.routeId
        let (envelope, url) = try await client.request(
            ArrivalInfoByRouteRequest(
                cityCode: baseScenario.cityCode,
                nodeId: baseScenario.nodeId,
                routeId: routeId ?? baseScenario.routeId
            )
        )
        print("[arrival-one] URL=\(url)")
        #expect(envelope.response.header.resultCode == "00")
        let items = envelope.response.body?.items?.item ?? []
        #expect(items.count >= 0)
    }

    private func fetchArrivalsList(client: BusAPIClient) async throws -> [BusArrivalInfo] {
        let (envelope, _) = try await client.request(
            ArrivalInfoByStopRequest(
                cityCode: baseScenario.cityCode,
                nodeId: baseScenario.nodeId,
                pageNo: 1,
                numOfRows: 10
            )
        )
        return envelope.response.body?.items?.item ?? []
    }

    // MARK: - Location

    @Test func busLocationsPaged_decodesItems() async throws {
        let client = makeClient()
        let (envelope, url) = try await client.request(
            BusLocationByRouteRequest(
                cityCode: baseScenario.cityCode,
                routeId: baseScenario.routeId,
                pageNo: 1,
                numOfRows: 10
            )
        )
        print("[location-page] URL=\(url)")
        #expect(envelope.response.header.resultCode == "00")
        let items = envelope.response.body?.items?.item ?? []
        #expect(items.count >= 0)
    }

    @Test func busLocationsSimple_decodesItems() async throws {
        let client = makeClient()
        let (envelope, url) = try await client.request(
            BusLocationByRouteSimpleRequest(
                cityCode: baseScenario.cityCode,
                routeId: baseScenario.routeId
            )
        )
        print("[location-simple] URL=\(url)")
        #expect(envelope.response.header.resultCode == "00")
    }

    @Test func busLocationsByStop_decodesItems() async throws {
        let client = makeClient()
        let (envelope, url) = try await client.request(
            BusLocationByStopRequest(
                cityCode: baseScenario.cityCode,
                routeId: baseScenario.routeId,
                nodeId: baseScenario.nodeId
            )
        )
        print("[location-stop] URL=\(url)")
        #expect(envelope.response.header.resultCode == "00")
    }

    // MARK: - Route

    @Test func routeInfo_decodesItems() async throws {
        let client = makeClient()
        let (envelope, url) = try await client.request(
            BusRouteInfoRequest(
                cityCode: baseScenario.cityCode,
                routeId: baseScenario.routeId
            )
        )
        print("[route-info] URL=\(url)")
        #expect(envelope.response.header.resultCode == "00")
        let items = envelope.response.body?.items?.item ?? []
        if let first = items.first {
            print("route info -> \(first.debugSummary)")
        }
    }

    @Test func routeList_decodesItems() async throws {
        let client = makeClient()
        let (envelope, url) = try await client.request(
            BusRouteListRequest(
                cityCode: baseScenario.cityCode,
                routeNumber: baseScenario.routeNo
            )
        )
        print("[route-list] URL=\(url)")
        #expect(envelope.response.header.resultCode == "00")
        let items = envelope.response.body?.items?.item ?? []
        #expect(items.count >= 0)
    }

    @Test func routePassingStops_decodesItems() async throws {
        let client = makeClient()
        let (envelope, url) = try await client.request(
            BusRoutePassingStopsRequest(
                cityCode: baseScenario.cityCode,
                routeId: baseScenario.routeId
            )
        )
        print("[route-stops] URL=\(url)")
        #expect(envelope.response.header.resultCode == "00")
    }
}
