import Foundation

enum MockData {
    // MARK: - BusStop

    static let stopsNearby: [BusStop] = [
        BusStop(
            nodeId: "PHB350099003",
            name: "포스텍",
            number: "299003",
            cityCode: 37010,
            latitude: 36.015169,
            longitude: 129.325127
        ),
        BusStop(
            nodeId: "PHB350099002",
            name: "생명공학연구소",
            number: "299002",
            cityCode: 37010,
            latitude: 36.012563,
            longitude: 129.326489
        ),
        BusStop(
            nodeId: "PHB350099016",
            name: "포스텍",
            number: "299016",
            cityCode: 37010,
            latitude: 36.016082,
            longitude: 129.324605
        ),
        BusStop(
            nodeId: "PHB350099017",
            name: "생명공학연구소",
            number: "299017",
            cityCode: 37010,
            latitude: 36.011751,
            longitude: 129.326565
        ),
        BusStop(
            nodeId: "PHB350099001",
            name: "효곡동행정복지센터",
            number: "299001",
            cityCode: 37010,
            latitude: 36.010473,
            longitude: 129.328355
        ),
    ]

    static let searchStops: [BusStop] = [
        BusStop(
            nodeId: "PHB350099003",
            name: "포스텍",
            number: "299003",
            cityCode: 37010,
            latitude: 36.015169,
            longitude: 129.325127
        ),
    ]

    // MARK: - BusRoute

    static let stopRoutes: [BusRoute] = [
        BusRoute(routeId: "PHB350000231", routeNumber: "207(기본)"),
        BusRoute(routeId: "PHB350000235", routeNumber: "306(기본)"),
    ]

    static let routeInfo: [BusRoute] = [
        BusRoute(routeId: "PHB350000231", routeNumber: "207(기본)"),
    ]

    static let searchRoutes: [BusRoute] = [
        BusRoute(routeId: "PHB350000231", routeNumber: "207(기본)"),
    ]

    // MARK: - BusLocation

    static let routeLocations: [BusLocation] = [
        BusLocation(
            routeId: "PHB350000235",
            routeNumber: "306(기본)",
            vehicleNumber: "1118",
            nodeId: "PHB350087178",
            nodeName: "문덕마을회관",
            latitude: 129.406425,
            longitude: 35.95358
        ),
        BusLocation(
            routeId: "PHB350000235",
            routeNumber: "306(기본)",
            vehicleNumber: "1117",
            nodeId: "PHB350097009",
            nodeName: "청림초등학교",
            latitude: 129.404846,
            longitude: 35.993605
        ),
        BusLocation(
            routeId: "PHB350000235",
            routeNumber: "306(기본)",
            vehicleNumber: "1310",
            nodeId: "PHB350000011",
            nodeName: "대잠사거리",
            latitude: 129.343966,
            longitude: 36.011553
        ),
        BusLocation(
            routeId: "PHB350000235",
            routeNumber: "306(기본)",
            vehicleNumber: "1347",
            nodeId: "PHB350099013",
            nodeName: "산책로",
            latitude: 129.320288,
            longitude: 36.026408
        ),
        BusLocation(
            routeId: "PHB350000235",
            routeNumber: "306(기본)",
            vehicleNumber: "1306",
            nodeId: "PHB350099189",
            nodeName: "LG빌라",
            latitude: 129.31438,
            longitude: 36.028269
        ),
        BusLocation(
            routeId: "PHB350000235",
            routeNumber: "306(기본)",
            vehicleNumber: "1322",
            nodeId: "PHB350000017",
            nodeName: "시청",
            latitude: 129.340727,
            longitude: 36.018006
        ),
        BusLocation(
            routeId: "PHB350000235",
            routeNumber: "306(기본)",
            vehicleNumber: "1257",
            nodeId: "PHB350087016",
            nodeName: "구정3리",
            latitude: 129.412562,
            longitude: 35.978774
        ),
    ]

    // MARK: - BusRouteStation

    static let routeStations: [BusRouteStation] = [
        BusRouteStation(stationId: "PHB350099003", stationName: "포스텍", latitude: 36.015169, longitude: 129.325127),
        BusRouteStation(stationId: "PHB350099002", stationName: "생명공학연구소", latitude: 36.012563, longitude: 129.326489),
    ]

    // MARK: - BusCity

    static let cities: [BusCity] = [
        BusCity(code: 37010, name: "포항시"),
    ]
}
