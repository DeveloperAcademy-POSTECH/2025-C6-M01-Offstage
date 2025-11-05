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
            self.provider = MoyaProvider<SeoulBusAPITarget>()
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
        // Prefer name search when available
        if let name = nodeName, !name.isEmpty {
            let response = try await provider.request(.getStationByName(name: name))
            let body = try decoder.decode(SeoulStopResponse.self, from: response.data)
            return body.msgBody.itemList.compactMap { adaptToBusStop(from: $0) }
        }

        // If only number provided, fallback to name-based search using number as query
        if let number = nodeNumber, !number.isEmpty {
            let response = try await provider.request(.getStationByName(name: number))
            let body = try decoder.decode(SeoulStopResponse.self, from: response.data)
            return body.msgBody.itemList.compactMap { adaptToBusStop(from: $0) }
        }

        return []
    }

    public func fetchStopsNearby(latitude: Double, longitude: Double, cityCode _: String?) async throws -> [BusStop] {
        // 서울 API는 WGS84 좌표를 그대로 사용 (tmX = longitude, tmY = latitude)
        let response = try await provider.request(.getStationByPos(tmX: longitude, tmY: latitude))
        let body = try decoder.decode(SeoulStopResponse.self, from: response.data)
        return body.msgBody.itemList.compactMap { adaptToBusStop(from: $0) }
    }

    public func fetchRoutesPassingThroughStop(cityCode _: String, nodeId _: String) async throws -> [BusRoute] {
        // Not directly supported by Seoul endpoints implemented here
        []
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

    private func adaptToBusStop(from dto: SeoulStopDTO) -> BusStop? {
        guard let lat = Double(dto.gpsY), let lon = Double(dto.gpsX) else { return nil }
        return BusStop(
            nodeId: dto.stId,
            name: dto.stNm,
            number: dto.arsId,
            cityCode: Int(1000), // 서울시는 1000으로 고정
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
