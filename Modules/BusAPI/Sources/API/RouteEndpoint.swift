import Foundation
import Moya

public enum RouteEndpoint {
    case getRouteInfo(cityCode: String, routeId: String)
    case searchRoute(cityCode: String, routeNo: String)
    case getRouteStops(cityCode: String, routeId: String)
}

extension RouteEndpoint: BusAPITarget {
    public var serviceKey: String {
        APIKeyProvider.routeServiceKey
    }

    public var path: String {
        switch self {
        case .getRouteInfo: "/BusRouteInfoInqireService/getRouteInfoIem"
        case .searchRoute: "/BusRouteInfoInqireService/getRouteNoList"
        case .getRouteStops: "/BusRouteInfoInqireService/getRouteAcctoThrghSttnList"
        }
    }

    public var task: Moya.Task {
        var parameters: [String: Any] = [:]
        switch self {
        case let .getRouteInfo(cityCode, routeId):
            parameters["cityCode"] = cityCode
            parameters["routeId"] = routeId
        case let .searchRoute(cityCode, routeNo):
            parameters["cityCode"] = cityCode
            parameters["routeNo"] = routeNo
            parameters["numOfRows"] = 30
        case let .getRouteStops(cityCode, routeId):
            parameters["cityCode"] = cityCode
            parameters["routeId"] = routeId
            parameters["numOfRows"] = 100
        }
        parameters["_type"] = "json"
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
    }

    public var sampleData: Data { Data() }
}
