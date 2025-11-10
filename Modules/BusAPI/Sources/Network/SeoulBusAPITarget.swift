// Modules/BusAPI/Sources/Network/SeoulBusAPITarget.swift
import Foundation
import Moya

//
public enum SeoulBusAPITarget {
    /// 1. 정류소 이름 검색 (getStationByName)
    case getStationByName(name: String)
    /// 2. 정류소 좌표 검색 (getStationByPos) - TM 좌표
    case getStationByPos(tmX: Double, tmY: Double)
    /// 3. 정류소 상세 (도착 정보) (getStationByUid)
    case getStationArrivals(arsId: String) // arsId = 정류소 번호 (nodeNo)
    /// 4. 노선 정보 (방향) (getBusRouteList)
    case getRouteInfo(routeId: String)
    /// 5. 정류소 경유 노선 목록 (getRouteByStation)
    case getRouteByStation(arsId: String)
    /// 6. 노선별 경유 정류소 목록 (getStaionByRoute)
    case getStaionByRoute(busRouteId: String)
    /// 7. 정류소-노선별 도착 정보 (getArrInfoByRoute)
    case getArrInfoByRoute(stId: String, busRouteId: String, ord: String)
    /// 8. 노선별 버스 위치 목록 (getBusPosByRtid)
    case getBusPosByRtid(busRouteId: String)
}

extension SeoulBusAPITarget: TargetType {
    public var baseURL: URL { URL(string: "http://ws.bus.go.kr/api/rest")! }

    public var path: String {
        switch self {
        case .getStationByName: "/stationinfo/getStationByName"
        case .getStationByPos: "/stationinfo/getStationByPos"
        case .getStationArrivals: "/stationinfo/getStationByUid"
        case .getRouteInfo: "/busRouteInfo/getBusRouteList"
        case .getRouteByStation: "/stationinfo/getRouteByStation"
        case .getStaionByRoute: "/busRouteInfo/getStaionByRoute"
        case .getArrInfoByRoute: "/arrive/getArrInfoByRoute"
        case .getBusPosByRtid: "/buspos/getBusPosByRtid"
        }
    }

    public var method: Moya.Method { .get }

    public var task: Task {
        // 1. serviceKey와 resultType=json은 공통 파라미터입니다.
        var params: [String: Any] = [
            "serviceKey": BusAPIKey.seoul, // Phase 1에서 추가한 키 로더 사용
            "resultType": "json",
        ]

        // 2. 케이스별 파라미터 추가
        switch self {
        case let .getStationByName(name):
            params["stSrch"] = name
        case let .getStationByPos(tmX, tmY):
            // GPS(WGS84) -> TM 좌표 변환은 Repository 단계에서 수행
            params["tmX"] = tmX
            params["tmY"] = tmY
            params["radius"] = 200 // 200m 반경
        case let .getStationArrivals(arsId):
            params["arsId"] = arsId //
        case let .getRouteInfo(routeId):
            params["busRouteId"] = routeId //
        case let .getRouteByStation(arsId):
            params["arsId"] = arsId
        case let .getStaionByRoute(busRouteId):
            params["busRouteId"] = busRouteId
        case let .getArrInfoByRoute(stId, busRouteId, ord):
            params["stId"] = stId
            params["busRouteId"] = busRouteId
            params["ord"] = ord
        case let .getBusPosByRtid(busRouteId):
            params["busRouteId"] = busRouteId
        }

        return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
    }

    public var headers: [String: String]? { nil }
    public var sampleData: Data { Data() }
}
