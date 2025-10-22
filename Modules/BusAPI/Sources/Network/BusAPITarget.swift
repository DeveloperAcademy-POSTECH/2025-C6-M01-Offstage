import Foundation
import Moya

public struct BusAPITarget: TargetType {
    public let endpoint: Endpoint
    let serviceKey: String

    public static func make(
        _ endpoint: Endpoint,
        keyProvider: (BusAPIService) throws -> String = { try BusAPIKey.value(for: $0) }
    ) throws -> BusAPITarget {
        let key = try keyProvider(endpoint.service)
        return BusAPITarget(endpoint: endpoint, serviceKey: key)
    }

    private init(endpoint: Endpoint, serviceKey: String) {
        self.endpoint = endpoint
        self.serviceKey = serviceKey
    }

    public var baseURL: URL {
        URL(string: "https://apis.data.go.kr/1613000")!
    }

    public var path: String {
        endpoint.path
    }

    public var method: Moya.Method {
        .get
    }

    public var sampleData: Data { Data() }

    public var task: Moya.Task {
        var parameters = endpoint.parameters
        parameters["_type"] = "json"
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
    }

    public var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}

public extension BusAPITarget {
    enum Endpoint {
        case cityCodes(service: BusAPIService)
        case routeLocations(cityCode: String, routeId: String, page: Int? = nil, rows: Int? = nil)
        case stopSearch(cityCode: String, nodeName: String?, nodeNumber: String?)
        case stopsNearby(latitude: Double, longitude: Double)
        case stopRoutes(cityCode: String, nodeId: String)
        case routeInfo(cityCode: String, routeId: String)
        case routeSearch(cityCode: String, routeNumber: String)
        case routeStations(cityCode: String, routeId: String)
        case stopArrivals(cityCode: String, nodeId: String)
        case routeArrivals(cityCode: String, nodeId: String, routeId: String)

        var service: BusAPIService {
            switch self {
            case let .cityCodes(service):
                service
            case .routeLocations:
                .location
            case .stopSearch, .stopsNearby, .stopRoutes:
                .stop
            case .routeInfo, .routeSearch, .routeStations:
                .route
            case .stopArrivals, .routeArrivals:
                .arrival
            }
        }

        var path: String {
            switch self {
            case let .cityCodes(service):
                switch service {
                case .location:
                    "/BusLcInfoInqireService/getCtyCodeList"
                case .stop:
                    "/BusSttnInfoInqireService/getCtyCodeList"
                case .route:
                    "/BusRouteInfoInqireService/getCtyCodeList"
                case .arrival:
                    "/ArvlInfoInqireService/getCtyCodeList"
                }
            case .routeLocations:
                "/BusLcInfoInqireService/getRouteAcctoBusLcList"
            case .stopSearch:
                "/BusSttnInfoInqireService/getSttnNoList"
            case .stopsNearby:
                "/BusSttnInfoInqireService/getCrdntPrxmtSttnList"
            case .stopRoutes:
                "/BusSttnInfoInqireService/getSttnThrghRouteList"
            case .routeInfo:
                "/BusRouteInfoInqireService/getRouteInfoIem"
            case .routeSearch:
                "/BusRouteInfoInqireService/getRouteNoList"
            case .routeStations:
                "/BusRouteInfoInqireService/getRouteAcctoThrghSttnList"
            case .stopArrivals:
                "/ArvlInfoInqireService/getSttnAcctoArvlPrearngeInfoList"
            case .routeArrivals:
                "/ArvlInfoInqireService/getSttnAcctoSpcifyRouteBusArvlPrearngeInfoList"
            }
        }

        var parameters: [String: Any] {
            let sanitized: [String: Any?] = switch self {
            case .cityCodes:
                [:]
            case let .routeLocations(cityCode, routeId, page, rows):
                [
                    "cityCode": cityCode,
                    "routeId": routeId,
                    "pageNo": page,
                    // "numOfRows": rows ?? 50,
                ]
            case let .stopSearch(cityCode, nodeName, nodeNumber):
                [
                    "cityCode": cityCode,
                    "nodeNm": nodeName,
                    "nodeNo": nodeNumber,
                    // "numOfRows": 30,
                ]
            case let .stopsNearby(latitude, longitude):
                [
                    "gpsLati": latitude,
                    "gpsLong": longitude,
                ]
            case let .stopRoutes(cityCode, nodeId):
                [
                    "cityCode": cityCode,
                    "nodeId": nodeId,
                    // "numOfRows": 50,
                ]
            case let .routeInfo(cityCode, routeId):
                [
                    "cityCode": cityCode,
                    "routeId": routeId,
                ]
            case let .routeSearch(cityCode, routeNumber):
                [
                    "cityCode": cityCode,
                    "routeNo": routeNumber,
                    // "numOfRows": 30,
                ]
            case let .routeStations(cityCode, routeId):
                [
                    "cityCode": cityCode,
                    "routeId": routeId,
                    // "numOfRows": 100,
                ]
            case let .stopArrivals(cityCode, nodeId):
                [
                    "cityCode": cityCode,
                    "nodeId": nodeId,
                    // "numOfRows": 50,
                ]
            case let .routeArrivals(cityCode, nodeId, routeId):
                [
                    "cityCode": cityCode,
                    "nodeId": nodeId,
                    "routeId": routeId,
                ]
            }
            return sanitized.compactMapValues { $0 }
        }
    }
}
