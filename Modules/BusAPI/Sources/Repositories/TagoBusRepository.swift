import Foundation
import Logging
import Moya

public final class TagoBusRepository: BusRepository {
    private let provider: MoyaProvider<BusAPITarget>
    private let decoder: JSONDecoder
    private let keyProvider: (BusAPIService) throws -> String
    private let logger = Logger(label: "BusAPI.TagoBusRepository")

    public init(
        provider: MoyaProvider<BusAPITarget>? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        keyProvider: @escaping (BusAPIService) throws -> String = { try BusAPIKey.value(for: $0) }
    ) {
        if let provider {
            self.provider = provider
        } else {
            let plugins: [PluginType] = [
                ServiceKeyPlugin(),
            ]
            self.provider = MoyaProvider<BusAPITarget>(plugins: plugins)
        }
        self.decoder = decoder
        self.keyProvider = keyProvider
    }

    public func fetchCities(for service: BusAPIService) async throws -> [BusCity] {
        try await items(for: .cityCodes(service: service), type: BusCity.self)
    }

    public func fetchRouteLocations(cityCode: String, routeId: String, page: Int?) async throws -> [BusLocation] {
        try await items(
            for: .routeLocations(cityCode: cityCode, routeId: routeId, page: page, rows: nil),
            type: BusLocation.self
        )
    }

    // 현재 선택된 도시 코드를 저장하는 프로퍼티
    private var currentCityCode: Int?

    public func searchStops(cityCode: String?, nodeName: String?, nodeNumber: String?) async throws -> [BusStop] {
        // 1. 직접 전달된 cityCode가 있으면 사용
        if let cityCode, !cityCode.isEmpty {
            return try await items(
                for: .stopSearch(cityCode: cityCode, nodeName: nodeName, nodeNumber: nodeNumber),
                type: BusStop.self
            )
        }

        // 2. GPS로 얻은 currentCityCode가 있으면 사용 (지역 제한 검색)
        if let currentCityCode {
            logger.info("Using GPS-based city code for local search: \(currentCityCode)")
            return try await items(
                for: .stopSearch(cityCode: String(currentCityCode), nodeName: nodeName, nodeNumber: nodeNumber),
                type: BusStop.self
            )
        }

        // 3. cityCode가 없고 GPS 기반 코드도 없는 경우
        throw BusAPIError.missingParameter(
            name: "cityCode (전국 검색은 지원되지 않습니다. GPS를 활성화하여 현재 지역을 선택하거나, 특정 도시를 선택해주세요)"
        )
    }

    public func fetchStopsNearby(latitude: Double, longitude: Double, cityCode _: String?) async throws -> [BusStop] {
        let stops = try await items(for: .stopsNearby(latitude: latitude, longitude: longitude), type: BusStop.self)

        // GPS 검색으로 얻은 첫 번째 정류장의 도시 코드를 저장
        if let firstStop = stops.first, let cityCode = firstStop.cityCode {
            currentCityCode = cityCode
            logger.info("Updated current city code from GPS search: \(cityCode)")
        }

        return stops
    }

    public func fetchRoutesPassingThroughStop(cityCode: String, nodeId: String) async throws -> [BusRoute] {
        try await items(for: .stopRoutes(cityCode: cityCode, nodeId: nodeId), type: BusRoute.self)
    }

    public func fetchRouteInfo(cityCode: String, routeId: String) async throws -> BusRoute? {
        try await items(for: .routeInfo(cityCode: cityCode, routeId: routeId), type: BusRoute.self).first
    }

    public func searchRoutes(cityCode: String, routeNumber: String) async throws -> [BusRoute] {
        try await items(for: .routeSearch(cityCode: cityCode, routeNumber: routeNumber), type: BusRoute.self)
    }

    public func fetchRouteStations(cityCode: String, routeId: String) async throws -> [BusRouteStation] {
        try await items(for: .routeStations(cityCode: cityCode, routeId: routeId), type: BusRouteStation.self)
    }

    public func fetchStopArrivals(cityCode: String, nodeId: String) async throws -> [BusArrival] {
        try await items(for: .stopArrivals(cityCode: cityCode, nodeId: nodeId), type: BusArrival.self)
    }

    public func fetchRouteArrivals(cityCode: String, nodeId: String, routeId: String) async throws -> [BusArrival] {
        try await items(
            for: .routeArrivals(cityCode: cityCode, nodeId: nodeId, routeId: routeId),
            type: BusArrival.self
        )
    }

    private func items<Item: Decodable>(
        for endpoint: BusAPITarget.Endpoint,
        type _: Item.Type
    ) async throws -> [Item] {
        let envelope: BusAPIEnvelope<Item> = try await fetch(endpoint: endpoint)
        return envelope.items
    }

    private func fetch<Item: Decodable>(endpoint: BusAPITarget.Endpoint) async throws -> BusAPIEnvelope<Item> {
        let target = try BusAPITarget.make(endpoint, keyProvider: keyProvider)

        let response: Response
        do {
            logger.info("➡️ Request: \(target.path) params: \(endpoint.parameters)")
            response = try await provider.request(target)
        } catch let error as MoyaError {
            throw BusAPIError.network(error)
        }

        guard !response.data.isEmpty else {
            throw BusAPIError.emptyBody
        }

        if let body = String(data: response.data, encoding: .utf8) {
            logger.info("⬅️ Response: \(target.path) status: \(response.statusCode)\n\(body)")
        } else {
            logger
                .info(
                    "⬅️ Response: \(target.path) status: \(response.statusCode) (non-UTF8 body, \(response.data.count) bytes)"
                )
        }

        let envelope: BusAPIEnvelope<Item>
        do {
            envelope = try decoder.decode(BusAPIEnvelope<Item>.self, from: response.data)
        } catch {
            logger.error("Decoding failed for \(target.path): \(error.localizedDescription)")
            throw BusAPIError.decodingFailed(error)
        }

        guard envelope.header.isSuccess else {
            throw BusAPIError.invalidStatus(header: envelope.header)
        }

        return envelope
    }
}
