import Foundation
import Moya

/// Describes the available endpoints exposed by the public bus API.
public enum BusAPI {
    // MARK: - Arrival Info

    case getArrivals(cityCode: String, nodeId: String)
    case getArrivalsForRoute(cityCode: String, nodeId: String, routeId: String)

    // MARK: - Location Info

    case getRouteBusLocations(cityCode: String, routeId: String)

    // MARK: - Stop Info

    case searchStop(cityCode: String, stopName: String)
    case getStopsByGps(gpsLati: Double, gpsLong: Double)
    case getStopRoutes(cityCode: String, nodeId: String)

    // MARK: - Route Info

    case getRouteInfo(cityCode: String, routeId: String)
    case searchRoute(cityCode: String, routeNo: String)
    case getRouteStops(cityCode: String, routeId: String)
}

extension BusAPI: TargetType {
    public var baseURL: URL {
        URL(string: "https://apis.data.go.kr/1613000")!
    }

    public var path: String {
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

    public var method: Moya.Method { .get }

    public var task: Moya.Task {
        let serviceKey = APIKeyProvider.busServiceKey
        var parameters: [String: Any] = ["serviceKey": serviceKey, "_type": "json"]

        switch self {
        case let .getArrivals(cityCode, nodeId):
            parameters["cityCode"] = cityCode
            parameters["nodeId"] = nodeId
            parameters["numOfRows"] = 50
        case let .getArrivalsForRoute(cityCode, nodeId, routeId):
            parameters["cityCode"] = cityCode
            parameters["nodeId"] = nodeId
            parameters["routeId"] = routeId
        case let .getRouteBusLocations(cityCode, routeId):
            parameters["cityCode"] = cityCode
            parameters["routeId"] = routeId
            parameters["numOfRows"] = 50
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

        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
    }

    public var headers: [String: String]? { ["Content-type": "application/json"] }

    public var sampleData: Data {
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
