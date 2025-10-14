import Foundation

/// 버스 공공데이터 API 요청을 표현하는 기본 프로토콜입니다.
protocol BusAPIRequest {
    associatedtype Response: Decodable
    /// API 서비스 경로입니다. 예: `ArvlInfoInqireService`
    var service: String { get }
    /// 서비스 내 세부 메서드 경로입니다. 예: `getSttnAcctoArvlPrearngeInfoList`
    var method: String { get }
    /// 쿼리 파라미터 목록입니다.
    var queryItems: [URLQueryItem] { get }
}

// MARK: - Arrival

/// 특정 정류소의 도착 정보 전체를 조회하는 요청입니다.
struct ArrivalInfoByStopRequest: BusAPIRequest {
    typealias Response = BusArrivalInfo

    let cityCode: String
    let nodeId: String
    let pageNo: Int
    let numOfRows: Int

    var service: String { "ArvlInfoInqireService" }
    var method: String { "getSttnAcctoArvlPrearngeInfoList" }
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "cityCode", value: cityCode),
            URLQueryItem(name: "nodeId", value: nodeId),
            URLQueryItem(name: "pageNo", value: String(pageNo)),
            URLQueryItem(name: "numOfRows", value: String(numOfRows)),
        ]
    }
}

/// 특정 노선이 특정 정류소로 접근할 때의 도착 정보를 조회하는 요청입니다.
struct ArrivalInfoByRouteRequest: BusAPIRequest {
    typealias Response = BusArrivalInfo

    let cityCode: String
    let nodeId: String
    let routeId: String

    var service: String { "ArvlInfoInqireService" }
    var method: String { "getSttnAcctoSpcifyRouteBusArvlPrearngeInfoList" }
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "cityCode", value: cityCode),
            URLQueryItem(name: "nodeId", value: nodeId),
            URLQueryItem(name: "routeId", value: routeId),
        ]
    }
}

/// 도시 코드 목록을 조회하는 요청입니다.
struct ArrivalCityCodeListRequest: BusAPIRequest {
    typealias Response = CityCode

    let pageNo: Int
    let numOfRows: Int

    init(pageNo: Int = 1, numOfRows: Int = 10) {
        self.pageNo = pageNo
        self.numOfRows = numOfRows
    }

    var service: String { "ArvlInfoInqireService" }
    var method: String { "getCtyCodeList" }
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "pageNo", value: String(pageNo)),
            URLQueryItem(name: "numOfRows", value: String(numOfRows)),
        ]
    }
}

// MARK: - Location

/// 노선별 실시간 버스 위치를 조회하는 요청입니다.
struct BusLocationByRouteRequest: BusAPIRequest {
    typealias Response = BusLocationInfo

    let cityCode: String
    let routeId: String
    let pageNo: Int
    let numOfRows: Int

    init(cityCode: String, routeId: String, pageNo: Int = 1, numOfRows: Int = 10) {
        self.cityCode = cityCode
        self.routeId = routeId
        self.pageNo = pageNo
        self.numOfRows = numOfRows
    }

    var service: String { "BusLcInfoInqireService" }
    var method: String { "getRouteAcctoBusLcList" }
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "cityCode", value: cityCode),
            URLQueryItem(name: "routeId", value: routeId),
            URLQueryItem(name: "pageNo", value: String(pageNo)),
            URLQueryItem(name: "numOfRows", value: String(numOfRows)),
        ]
    }
}

/// 노선별 실시간 버스 위치를 조회하되 페이지 정보를 생략할 수 있는 요청입니다.
struct BusLocationByRouteSimpleRequest: BusAPIRequest {
    typealias Response = BusLocationInfo

    let cityCode: String
    let routeId: String

    var service: String { "BusLcInfoInqireService" }
    var method: String { "getRouteAcctoBusLcList" }
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "cityCode", value: cityCode),
            URLQueryItem(name: "routeId", value: routeId),
        ]
    }
}

/// 특정 정류소에 접근 중인 버스 위치를 조회하는 요청입니다.
struct BusLocationByStopRequest: BusAPIRequest {
    typealias Response = BusLocationInfo

    let cityCode: String
    let routeId: String
    let nodeId: String

    var service: String { "BusLcInfoInqireService" }
    var method: String { "getRouteAcctoSpcifySttnAccesBusLcInfo" }
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "cityCode", value: cityCode),
            URLQueryItem(name: "routeId", value: routeId),
            URLQueryItem(name: "nodeId", value: nodeId),
        ]
    }
}

// MARK: - Stops

/// 정류소 이름 또는 번호로 정류소 목록을 조회하는 요청입니다.
struct StationListRequest: BusAPIRequest {
    typealias Response = BusStopInfo

    let cityCode: String
    let nodeName: String?
    let nodeNumber: String?
    let pageNo: Int
    let numOfRows: Int

    init(
        cityCode: String,
        nodeName: String? = nil,
        nodeNumber: String? = nil,
        pageNo: Int = 1,
        numOfRows: Int = 10
    ) {
        self.cityCode = cityCode
        self.nodeName = nodeName
        self.nodeNumber = nodeNumber
        self.pageNo = pageNo
        self.numOfRows = numOfRows
    }

    var service: String { "BusSttnInfoInqireService" }
    var method: String { "getSttnNoList" }
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "cityCode", value: cityCode),
            URLQueryItem(name: "nodeNm", value: nodeName ?? ""),
            URLQueryItem(name: "nodeNo", value: nodeNumber ?? ""),
            URLQueryItem(name: "pageNo", value: String(pageNo)),
            URLQueryItem(name: "numOfRows", value: String(numOfRows)),
        ]
    }
}

/// 좌표 기준으로 인근 정류장을 조회하는 요청입니다.
struct StationsByLocationRequest: BusAPIRequest {
    typealias Response = BusStopInfo

    let latitude: String
    let longitude: String

    var service: String { "BusSttnInfoInqireService" }
    var method: String { "getCrdntPrxmtSttnList" }
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "gpsLati", value: latitude),
            URLQueryItem(name: "gpsLong", value: longitude),
        ]
    }
}

/// 특정 정류장을 지나는 노선 목록을 조회하는 요청입니다.
struct RouteByStationRequest: BusAPIRequest {
    typealias Response = BusStopInfo

    let cityCode: String
    let nodeId: String

    var service: String { "BusSttnInfoInqireService" }
    var method: String { "getSttnThrghRouteList" }
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "cityCode", value: cityCode),
            URLQueryItem(name: "nodeId", value: nodeId),
        ]
    }
}

/// 정류소 서비스의 도시 코드 목록을 조회하는 요청입니다.
struct StationCityCodeListRequest: BusAPIRequest {
    typealias Response = CityCode

    let pageNo: Int
    let numOfRows: Int

    init(pageNo: Int = 1, numOfRows: Int = 10) {
        self.pageNo = pageNo
        self.numOfRows = numOfRows
    }

    var service: String { "BusSttnInfoInqireService" }
    var method: String { "getCtyCodeList" }
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "pageNo", value: String(pageNo)),
            URLQueryItem(name: "numOfRows", value: String(numOfRows)),
        ]
    }
}

// MARK: - Route

/// 특정 노선의 기본 정보를 조회하는 요청입니다.
struct BusRouteInfoRequest: BusAPIRequest {
    typealias Response = BusRouteInfo

    let cityCode: String
    let routeId: String

    var service: String { "BusRouteInfoInqireService" }
    var method: String { "getRouteInfoIem" }
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "cityCode", value: cityCode),
            URLQueryItem(name: "routeId", value: routeId),
        ]
    }
}

/// 특정 노선 번호와 일치하는 노선 목록을 조회하는 요청입니다.
struct BusRouteListRequest: BusAPIRequest {
    typealias Response = BusRouteInfo

    let cityCode: String
    let routeNumber: String

    var service: String { "BusRouteInfoInqireService" }
    var method: String { "getRouteNoList" }
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "cityCode", value: cityCode),
            URLQueryItem(name: "routeNo", value: routeNumber),
        ]
    }
}

/// 특정 노선이 지나는 정류장 목록을 조회하는 요청입니다.
struct BusRoutePassingStopsRequest: BusAPIRequest {
    typealias Response = BusRouteInfo

    let cityCode: String
    let routeId: String

    var service: String { "BusRouteInfoInqireService" }
    var method: String { "getRouteAcctoThrghSttnList" }
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "cityCode", value: cityCode),
            URLQueryItem(name: "routeId", value: routeId),
        ]
    }
}
