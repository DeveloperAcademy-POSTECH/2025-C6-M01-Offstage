import Foundation
import Moya

enum BusAPI {
    // Arrival Info
    case getArrivals(cityCode: String, nodeId: String)
    case getArrivalsForRoute(cityCode: String, nodeId: String, routeId: String)

    // Location Info
    case getRouteBusLocations(cityCode: String, routeId: String)

    // Stop Info
    case searchStop(cityCode: String, stopName: String)
    case getStopsByGps(gpsLati: Double, gpsLong: Double)
    case getStopRoutes(cityCode: String, nodeId: String)

    // Route Info
    case getRouteInfo(cityCode: String, routeId: String)
    case searchRoute(cityCode: String, routeNo: String)
    case getRouteStops(cityCode: String, routeId: String)
}

extension BusAPI: TargetType {
    var baseURL: URL {
        URL(string: "https://apis.data.go.kr/1613000")!
    }

    var path: String {
        switch self {
        case .getArrivals: "/ArvlInfoInqireService/getSttnAcctoArvlPrearngeInfoList"
        case .getArrivalsForRoute: "/ArvlInfoInqireService/getSttnAcctoSpcifyRouteBusArvlPrearngeInfoList"
        case .getRouteBusLocations: "/BusLcInfoInqireService/getRouteAcctoBusLcList"
        case .searchStop: "/BusSttnInfoInqireService/getSttnNoList"
        case .getStopsByGps: "/BusSttnInfoInqireService/getCrdntPrxmtSttnList"
        case .getStopRoutes: "/BusSttnInfoInqireService/getSttnThrghRouteList"
        case .getRouteInfo: "/BusRouteInfoInqireService/getRouteInfoIem"
        case .searchRoute: "/BusRouteInfoInqireService/getRouteNoList"
        case .getRouteStops: "/BusRouteInfoInqireService/getRouteAcctoThrghSttnList"
        }
    }

    var method: Moya.Method { .get }

    var task: Moya.Task {
        let serviceKey = APIKeyProvider.busServiceKey
        var p: [String: Any] = ["serviceKey": serviceKey, "_type": "json"]

        switch self {
        case let .getArrivals(cityCode, nodeId):
            p["cityCode"] = cityCode
            p["nodeId"] = nodeId
            p["numOfRows"] = 50
        case let .getArrivalsForRoute(cityCode, nodeId, routeId):
            p["cityCode"] = cityCode
            p["nodeId"] = nodeId
            p["routeId"] = routeId
        case let .getRouteBusLocations(cityCode, routeId):
            p["cityCode"] = cityCode
            p["routeId"] = routeId
            p["numOfRows"] = 50
        case let .searchStop(cityCode, stopName):
            p["cityCode"] = cityCode
            p["nodeNm"] = stopName
            p["numOfRows"] = 30
        case let .getStopsByGps(gpsLati, gpsLong):
            p["gpsLati"] = gpsLati
            p["gpsLong"] = gpsLong
        case let .getStopRoutes(cityCode, nodeId):
            p["cityCode"] = cityCode
            p["nodeId"] = nodeId
            p["numOfRows"] = 50
        case let .getRouteInfo(cityCode, routeId):
            p["cityCode"] = cityCode
            p["routeId"] = routeId
        case let .searchRoute(cityCode, routeNo):
            p["cityCode"] = cityCode
            p["routeNo"] = routeNo
            p["numOfRows"] = 30
        case let .getRouteStops(cityCode, routeId):
            p["cityCode"] = cityCode
            p["routeId"] = routeId
            p["numOfRows"] = 100
        }

        return .requestParameters(parameters: p, encoding: URLEncoding.queryString)
    }

    var headers: [String: String]? { ["Content-type": "application/json"] }

    var sampleData: Data {
        switch self {
        case .getArrivals, .getArrivalsForRoute:
            mockResponse(for: BusArrivalInfo.sample)
        case .searchStop, .getStopsByGps, .getRouteStops:
            mockResponse(for: BusStop.sample)
        case .getRouteBusLocations:
            mockResponse(for: BusLocation.sample)
        case .getStopRoutes:
            mockResponse(for: StationRoute.sample)
        case .getRouteInfo, .searchRoute:
            mockResponse(for: BusRoute.sample)
        }
    }

    private func mockResponse(for item: some Codable) -> Data {
        let response = ApiResponse(
            response: ResponseBody(
                header: ResponseHeader(resultCode: "00", resultMsg: "NORMAL SERVICE."),
                body: ItemBody(items: ItemWrapper(item: [item]), numOfRows: 1, pageNo: 1, totalCount: 1)
            )
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(response)
        return data ?? Data()
    }
}
