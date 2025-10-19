import Foundation
import Moya

public enum ArrivalEndpoint {
    case getArrivals(cityCode: String, nodeId: String)
    case getArrivalsForRoute(cityCode: String, nodeId: String, routeId: String)
}

extension ArrivalEndpoint: BusAPITarget {
    public var serviceKey: String {
        APIKeyProvider.arrivalServiceKey
    }

    public var path: String {
        switch self {
        case .getArrivals: "/ArvlInfoInqireService/getSttnAcctoArvlPrearngeInfoList"
        case .getArrivalsForRoute: "/ArvlInfoInqireService/getSttnAcctoSpcifyRouteBusArvlPrearngeInfoList"
        }
    }

    public var task: Moya.Task {
        var parameters: [String: Any] = [:]
        switch self {
        case let .getArrivals(cityCode, nodeId):
            parameters["cityCode"] = cityCode
            parameters["nodeId"] = nodeId
            parameters["numOfRows"] = 50
        case let .getArrivalsForRoute(cityCode, nodeId, routeId):
            parameters["cityCode"] = cityCode
            parameters["nodeId"] = nodeId
            parameters["routeId"] = routeId
        }
        parameters["_type"] = "json"
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
    }

    public var sampleData: Data { Data() }
}
