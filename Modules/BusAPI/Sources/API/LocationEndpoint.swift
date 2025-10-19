import Foundation
import Moya

public enum LocationEndpoint {
    case getRouteBusLocations(cityCode: String, routeId: String)
}

extension LocationEndpoint: BusAPITarget {
    public var serviceKey: String {
        APIKeyProvider.locationServiceKey
    }

    public var path: String {
        switch self {
        case .getRouteBusLocations: "/BusLcInfoInqireService/getRouteAcctoBusLcList"
        }
    }

    public var task: Moya.Task {
        var parameters: [String: Any] = [:]
        switch self {
        case let .getRouteBusLocations(cityCode, routeId):
            parameters["cityCode"] = cityCode
            parameters["routeId"] = routeId
            parameters["numOfRows"] = 50
        }
        parameters["_type"] = "json"
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
    }

    public var sampleData: Data { Data() }
}
