import Foundation
import Moya

public enum StopEndpoint {
    case searchStop(cityCode: String, stopName: String)
    case getStopsByGps(gpsLati: Double, gpsLong: Double)
    case getStopRoutes(cityCode: String, nodeId: String)
}

extension StopEndpoint: BusAPITarget {
    public var serviceKey: String {
        APIKeyProvider.stopServiceKey
    }

    public var path: String {
        switch self {
        case .searchStop: "/BusSttnInfoInqireService/getSttnNoList"
        case .getStopsByGps: "/BusSttnInfoInqireService/getCrdntPrxmtSttnList"
        case .getStopRoutes: "/BusSttnInfoInqireService/getSttnThrghRouteList"
        }
    }

    public var task: Moya.Task {
        var parameters: [String: Any] = [:]
        switch self {
        case let .searchStop(cityCode, stopName):
            parameters["cityCode"] = cityCode
            parameters["nodeNm"] = stopName
            parameters["numOfRows"] = 30
        case let .getStopsByGps(gpsLati, gpsLong):
            parameters["gpsLati"] = gpsLati
            parameters["gpsLong"] = gpsLong
        case let .getStopRoutes(cityCode, nodeId):
            parameters["cityCode"] = cityCode
            parameters["nodeId"] = nodeId
            parameters["numOfRows"] = 50
        }
        parameters["_type"] = "json"
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
    }
}
