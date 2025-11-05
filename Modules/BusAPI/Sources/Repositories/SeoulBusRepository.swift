import Foundation
import Logging
import Moya

public final class SeoulBusRepository: BusRepository {
    private let provider: MoyaProvider<SeoulBusAPITarget>
    private let decoder: JSONDecoder
    private let logger = Logger(label: "BusAPI.SeoulBusRepository")

    public init(provider: MoyaProvider<SeoulBusAPITarget>? = nil, decoder: JSONDecoder = JSONDecoder()) {
        if let provider {
            self.provider = provider
        } else {
            // NetworkLoggerPlugin을 추가하여 API 요청 및 응답을 로깅합니다.
            self.provider = MoyaProvider<SeoulBusAPITarget>(plugins: [NetworkLoggerPlugin()])
        }
        self.decoder = decoder
    }

    public func fetchCities(for _: BusAPIService) async throws -> [BusCity] {
        // 서울시는 별도의 도시 목록 API를 사용하지 않음. 빈 배열 반환.
        []
    }

    public func fetchRouteLocations(cityCode _: String, routeId _: String, page _: Int?) async throws -> [BusLocation] {
        // 서울 API의 경우 별도 구현이 필요. 일단 미지원으로 빈 배열 반환.
        []
    }

    public func searchStops(cityCode _: String?, nodeName: String?, nodeNumber: String?) async throws -> [BusStop] {
        // [수정] 서울 키워드 검색 DTO를 사용
        if let name = nodeName, !name.isEmpty {
            let response = try await provider.request(.getStationByName(name: name))
            // [수정] SeoulStopResponse -> SeoulKeywordStopResponse
            let body = try decoder.decode(SeoulKeywordStopResponse.self, from: response.data)
            // [수정] adaptToBusStop(from: SeoulKeywordStopDTO) 헬퍼 사용
            return body.msgBody.itemList.compactMap { adaptToBusStop(from: $0) }
        }

        if let number = nodeNumber, !number.isEmpty {
            let response = try await provider.request(.getStationByName(name: number))
            // [수정] SeoulStopResponse -> SeoulKeywordStopResponse
            let body = try decoder.decode(SeoulKeywordStopResponse.self, from: response.data)
            // [수정] adaptToBusStop(from: SeoulKeywordStopDTO) 헬퍼 사용
            return body.msgBody.itemList.compactMap { adaptToBusStop(from: $0) }
        }
        return []
    }

    public func fetchStopsNearby(latitude: Double, longitude: Double, cityCode _: String?) async throws -> [BusStop] {
        // 서울 API는 WGS84 좌표를 그대로 사용 (tmX = longitude, tmY = latitude)
        let response = try await provider.request(.getStationByPos(tmX: longitude, tmY: latitude))
        // [수정] SeoulStopResponse -> SeoulGpsStopResponse
        let body = try decoder.decode(SeoulGpsStopResponse.self, from: response.data)
        // [수정] adaptToBusStop(from: SeoulGpsStopDTO) 헬퍼 사용
        return body.msgBody.itemList.compactMap { adaptToBusStop(from: $0) }
    }

    public func fetchRoutesPassingThroughStop(cityCode _: String, nodeId: String) async throws -> [BusRoute] {
        let response = try await provider.request(.getRouteByStation(arsId: nodeId))
        let body = try decoder.decode(SeoulStationRouteResponse.self, from: response.data)

        return body.msgBody.itemList.map { dto in
            BusRoute(
                routeId: dto.busRouteId,
                routeNumber: dto.busRouteNm,
                routeType: "", // Not provided by this API
                startStopName: "",
                endStopName: "",
                startTime: "",
                endTime: ""
            )
        }
    }

    public func fetchRouteInfo(cityCode _: String, routeId: String) async throws -> BusRoute? {
        let response = try await provider.request(.getRouteInfo(routeId: routeId))
        let body = try decoder.decode(SeoulRouteInfoResponse.self, from: response.data)
        return body.msgBody.itemList.first.map { adaptToBusRoute(from: $0) }
    }

    public func searchRoutes(cityCode _: String, routeNumber: String) async throws -> [BusRoute] {
        // Seoul API's getBusRouteList supports searching by routeId/name; here we pass routeNumber
        let response = try await provider.request(.getRouteInfo(routeId: routeNumber))
        let body = try decoder.decode(SeoulRouteInfoResponse.self, from: response.data)
        return body.msgBody.itemList.map { adaptToBusRoute(from: $0) }
    }

    public func fetchRouteStations(cityCode _: String, routeId _: String) async throws -> [BusRouteStation] {
        // Not implemented: would require a different Seoul API endpoint and DTOs
        []
    }

    public func fetchStopArrivals(cityCode _: String, nodeId: String) async throws -> [BusArrival] {
        // Seoul API expects arsId (정류소번호) for station arrival query
        let response = try await provider.request(.getStationArrivals(arsId: nodeId))
        let body = try decoder.decode(SeoulArrivalResponse.self, from: response.data)

        let arrivals = body.msgBody.itemList.flatMap { dto in
            adaptToBusArrival(from: dto, nodeId: nodeId, nodeName: nil)
        }
        return arrivals
    }

    public func fetchRouteArrivals(cityCode: String, nodeId: String, routeId: String) async throws -> [BusArrival] {
        // Seoul API doesn't provide a combined node+route arrival endpoint in the current Target; fallback to
        // fetchStopArrivals and filter
        let all = try await fetchStopArrivals(cityCode: cityCode, nodeId: nodeId)
        return all.filter { $0.routeId == routeId }
    }

    // MARK: - Adapter helpers

    // [수정] GPS 검색용 헬퍼
    private func adaptToBusStop(from dto: SeoulGpsStopDTO) -> BusStop? {
        guard let lat = Double(dto.gpsY), let lon = Double(dto.gpsX) else { return nil }
        return BusStop(
            nodeId: dto.arsId, // 'arsId' 사용
            name: dto.stationNm, // 'stationNm' 사용
            number: dto.arsId,
            cityCode: Int(1000),
            direction: nil,
            latitude: lat,
            longitude: lon
        )
    }

    // [추가] 키워드 검색용 헬퍼
    private func adaptToBusStop(from dto: SeoulKeywordStopDTO) -> BusStop? {
        guard let lat = Double(dto.tmY), let lon = Double(dto.tmX) else { return nil }
        return BusStop(
            nodeId: dto.arsId, // 'arsId' 사용
            name: dto.stNm, // 'stNm' 사용
            number: dto.arsId,
            cityCode: Int(1000),
            direction: nil,
            latitude: lat,
            longitude: lon
        )
    }

    private func adaptToBusArrival(from dto: SeoulArrivalDTO, nodeId: String, nodeName: String?) -> [BusArrival] {
        var results: [BusArrival] = []

        let candidates = [dto.arrmsg1, dto.arrmsg2]
        for msg in candidates {
            guard let parsed = SeoulArrivalParser.parse(msg) else { continue }

            let arrival = BusArrival(
                routeId: dto.busRouteId,
                routeNumber: dto.rtNm,
                routeType: "",
                nodeId: nodeId,
                nodeName: nodeName ?? "",
                remainingStopCount: parsed.remainingStops,
                estimatedArrivalTime: parsed.seconds,
                vehicleType: nil
            )
            results.append(arrival)
        }

        return results
    }

    private func adaptToBusRoute(from dto: SeoulRouteInfoDTO) -> BusRoute {
        BusRoute(
            routeId: dto.busRouteId,
            routeNumber: dto.busRouteNm,
            routeType: dto.routeType,
            startStopName: dto.stStationNm,
            endStopName: dto.edStationNm,
            startTime: nil,
            endTime: nil
        )
    }
}
