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

    // MARK: - BusRepository Conformance

    public func fetchRouteLocations(cityCode _: String, routeId: String, page _: Int?) async throws -> [BusLocation] {
        let response = try await provider.request(.getBusPosByRtid(busRouteId: routeId))
        let body = try decoder.decode(SeoulBusLocationResponse.self, from: response.data)
        return body.msgBody.itemList.compactMap { dto in
            guard let lat = Double(dto.posY ?? "0"),
                  let lon = Double(dto.posX ?? "0")
            else { return nil }

            return BusLocation(
                routeId: routeId,
                routeNumber: "", // Not provided
                routeType: dto.busType == "1" ? "저상버스" : "일반버스",
                vehicleNumber: dto.plainNo ?? "",
                nodeId: dto.lastStnId ?? "",
                nodeName: "", // Not provided
                nodeOrder: 0, // Not provided
                latitude: lat,
                longitude: lon
            )
        }
    }

    public func fetchRouteStations(cityCode _: String, routeId: String) async throws -> [BusRouteStation] {
        let response = try await provider.request(.getStaionByRoute(busRouteId: routeId))
        let body = try decoder.decode(SeoulRouteStationResponse.self, from: response.data)

        return body.msgBody.itemList.compactMap { dto in
            guard let stationOrder = Int(dto.nodeOrd),
                  let lat = Double(dto.gpsY),
                  let lon = Double(dto.gpsX)
            else {
                logger.warning("Failed to parse SeoulRouteStationDTO: \(dto)")
                return nil
            }
            return BusRouteStation(
                stationId: dto.arsId,
                internalId: dto.station,
                stationName: dto.nodeNm,
                stationOrder: stationOrder,
                turnYn: nil, // Not available in this DTO
                latitude: lat,
                longitude: lon
            )
        }
    }

    public func searchStops(cityCode _: String?, nodeName: String?, nodeNumber: String?) async throws -> [BusStop] {
        if let name = nodeName, !name.isEmpty {
            let response = try await provider.request(.getStationByName(name: name))
            let body = try decoder.decode(SeoulKeywordStopResponse.self, from: response.data)
            return body.msgBody.itemList.compactMap { adaptToBusStop(from: $0) }
        }

        if let number = nodeNumber, !number.isEmpty {
            let response = try await provider.request(.getStationByName(name: number))
            let body = try decoder.decode(SeoulKeywordStopResponse.self, from: response.data)
            return body.msgBody.itemList.compactMap { adaptToBusStop(from: $0) }
        }
        return []
    }

    public func fetchStopsNearby(latitude: Double, longitude: Double, cityCode _: String?) async throws -> [BusStop] {
        let response = try await provider.request(.getStationByPos(tmX: longitude, tmY: latitude))
        let body = try decoder.decode(SeoulGpsStopResponse.self, from: response.data)
        return body.msgBody.itemList.compactMap { adaptToBusStop(from: $0) }
    }

    public func fetchRoutesPassingThroughStop(cityCode _: String, nodeId: String) async throws -> [BusRoute] {
        let response = try await provider.request(.getRouteByStation(arsId: nodeId))
        let body = try decoder.decode(SeoulStationRouteResponse.self, from: response.data)

        return body.msgBody.itemList.map { dto in
            BusRoute(
                routeId: dto.busRouteId,
                routeNumber: dto.busRouteNm
            )
        }
    }

    public func fetchRouteInfo(cityCode _: String, routeId: String) async throws -> BusRoute? {
        let response = try await provider.request(.getRouteInfo(routeId: routeId))
        let body = try decoder.decode(SeoulRouteInfoResponse.self, from: response.data)
        return body.msgBody.itemList.first.map { adaptToBusRoute(from: $0) }
    }

    public func searchRoutes(cityCode _: String, routeNumber: String) async throws -> [BusRoute] {
        let response = try await provider.request(.getRouteInfo(routeId: routeNumber))
        let body = try decoder.decode(SeoulRouteInfoResponse.self, from: response.data)
        return body.msgBody.itemList.map { adaptToBusRoute(from: $0) }
    }

    public func fetchStopArrivals(cityCode _: String, nodeId: String) async throws -> [BusArrival] {
        let response = try await provider.request(.getStationArrivals(arsId: nodeId))
        let body = try decoder.decode(SeoulArrivalResponse.self, from: response.data)

        let arrivals = body.msgBody.itemList.flatMap { dto in
            adaptToBusArrival(from: dto, nodeId: nodeId, nodeName: nil)
        }
        return arrivals
    }

    public func fetchRouteArrivals(cityCode: String, nodeId: String, routeId: String) async throws -> [BusArrival] {
        let all = try await fetchStopArrivals(cityCode: cityCode, nodeId: nodeId)
        return all.filter { $0.routeId == routeId }
    }

    // MARK: - Adapter helpers

    private func adaptToBusStop(from dto: SeoulGpsStopDTO) -> BusStop? {
        guard let lat = Double(dto.gpsY), let lon = Double(dto.gpsX) else { return nil }
        return BusStop(
            nodeId: dto.arsId,
            name: dto.stationNm,
            number: dto.arsId,
            cityCode: 1000,
            direction: nil,
            latitude: lat,
            longitude: lon
        )
    }

    private func adaptToBusStop(from dto: SeoulKeywordStopDTO) -> BusStop? {
        guard let lat = Double(dto.tmY), let lon = Double(dto.tmX) else { return nil }
        return BusStop(
            nodeId: dto.arsId,
            name: dto.stNm,
            number: dto.arsId,
            cityCode: 1000,
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
            routeNumber: dto.busRouteNm
        )
    }

    private func adaptToBusLocation(from dto: SeoulBusLocationDTO, routeId: String) -> BusLocation? {
        guard let lat = Double(dto.posY ?? "0"), let lon = Double(dto.posX ?? "0") else { return nil }
        return BusLocation(
            routeId: routeId,
            routeNumber: "", // Not provided
            routeType: dto.busType == "1" ? "저상버스" : "일반버스",
            vehicleNumber: dto.plainNo ?? "",
            nodeId: dto.lastStnId ?? "",
            nodeName: "", // Not provided
            nodeOrder: 0, // Not provided
            latitude: lat,
            longitude: lon
        )
    }
}
