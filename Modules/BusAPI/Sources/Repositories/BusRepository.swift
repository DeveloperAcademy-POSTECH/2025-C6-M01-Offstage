import Foundation

public protocol BusRepository {
    /**
     특정 버스 API 서비스에서 지원하는 도시 목록을 가져옵니다.
     - Parameter service: 도시 목록을 조회할 버스 API 서비스 (예: TAGO, Seoul).
     - Returns: `BusCity` 객체의 배열을 반환합니다.
     */
    func fetchCities(for service: BusAPIService) async throws -> [BusCity]

    /**
     특정 노선의 실시간 버스 위치 정보를 가져옵니다.
     - Parameters:
        - cityCode: 버스 노선이 운행되는 도시의 코드.
        - routeId: 조회할 버스 노선의 ID.
        - page: API가 페이지네이션을 지원하는 경우 사용할 페이지 번호 (선택 사항).
     - Returns: 각 버스의 현재 위치를 나타내는 `BusLocation` 객체의 배열을 반환합니다.
     */
    func fetchRouteLocations(cityCode: String, routeId: String, page: Int?) async throws -> [BusLocation]

    /**
     정류장 이름 또는 번호로 버스 정류장을 검색합니다.
     - Parameters:
        - cityCode: 검색 범위를 좁히기 위한 도시 코드 (선택 사항).
        - nodeName: 검색할 버스 정류장의 이름.
        - nodeNumber: 검색할 버스 정류장의 번호/ID.
     - Returns: 검색 조건과 일치하는 `BusStop` 객체의 배열을 반환합니다.
     */
    func searchStops(cityCode: String?, nodeName: String?, nodeNumber: String?) async throws -> [BusStop]

    /**
     주어진 지리적 좌표 근처의 버스 정류장을 가져옵니다.
     - Parameters:
        - latitude: 위치의 위도.
        - longitude: 위치의 경도.
        - cityCode: 검색 범위를 좁히기 위한 도시 코드 (선택 사항).
     - Returns: 근처에 위치한 `BusStop` 객체의 배열을 반환합니다.
     */
    func fetchStopsNearby(latitude: Double, longitude: Double, cityCode: String?) async throws -> [BusStop]

    /**
     특정 버스 정류장을 통과하는 모든 버스 노선을 가져옵니다.
     - Parameters:
        - cityCode: 버스 정류장이 위치한 도시의 코드.
        - nodeId: 조회할 버스 정류장의 ID.
     - Returns: 해당 정류장을 통과하는 `BusRoute` 객체의 배열을 반환합니다.
     */
    func fetchRoutesPassingThroughStop(cityCode: String, nodeId: String) async throws -> [BusRoute]

    /**
     특정 버스 노선의 상세 정보를 가져옵니다.
     - Parameters:
        - cityCode: 버스 노선이 운행되는 도시의 코드.
        - routeId: 조회할 버스 노선의 ID.
     - Returns: 노선의 상세 정보를 담은 `BusRoute` 객체 (선택 사항)를 반환합니다.
     */
    func fetchRouteInfo(cityCode: String, routeId: String) async throws -> BusRoute?

    /**
     버스 노선 번호/이름으로 버스 노선을 검색합니다.
     - Parameters:
        - cityCode: 검색할 도시의 코드.
        - routeNumber: 검색할 노선의 번호 또는 이름.
     - Returns: 검색어와 일치하는 `BusRoute` 객체의 배열을 반환합니다.
     */
    func searchRoutes(cityCode: String, routeNumber: String) async throws -> [BusRoute]

    /**
     특정 버스 노선이 운행하는 모든 정류장 목록을 순서대로 가져옵니다.
     - Parameters:
        - cityCode: 노선이 운행되는 도시의 코드.
        - routeId: 조회할 노선의 ID.
     - Returns: `BusRouteStation` 객체의 배열을 반환합니다.
     */
    func fetchRouteStations(cityCode: String, routeId: String) async throws -> [BusRouteStation]

    /**
     특정 정류장에 도착 예정인 모든 버스의 도착 정보를 가져옵니다.
     - Parameters:
        - cityCode: 정류장이 위치한 도시의 코드.
        - nodeId: 조회할 정류장의 ID.
     - Returns: 각 도착 예정 버스를 나타내는 `BusArrival` 객체의 배열을 반환합니다.
     */
    func fetchStopArrivals(cityCode: String, nodeId: String) async throws -> [BusArrival]

    /**
     특정 정류장에서 특정 노선의 도착 정보를 가져옵니다.
     - Parameters:
        - cityCode: 정류장이 위치한 도시의 코드.
        - nodeId: 조회할 정류장의 ID.
        - routeId: 도착 정보를 조회할 노선의 ID.
     - Returns: 지정된 노선 및 정류장에 대한 `BusArrival` 객체의 배열을 반환합니다.
     */
    func fetchRouteArrivals(cityCode: String, nodeId: String, routeId: String) async throws -> [BusArrival]
}

public extension BusRepository {
    func fetchRouteLocations(cityCode: String, routeId: String) async throws -> [BusLocation] {
        try await fetchRouteLocations(cityCode: cityCode, routeId: routeId, page: nil)
    }

    func searchStops(cityCode: String?, keyword: String) async throws -> [BusStop] {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let isNumeric = trimmed.allSatisfy(\.isNumber)
        let nodeName = isNumeric ? nil : trimmed
        let nodeNumber = isNumeric ? trimmed : nil
        return try await searchStops(cityCode: cityCode, nodeName: nodeName, nodeNumber: nodeNumber)
    }
}
