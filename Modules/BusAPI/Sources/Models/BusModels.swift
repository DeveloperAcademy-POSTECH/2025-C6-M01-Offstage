import Foundation

// MARK: - Generic API Response Wrappers

public struct ApiResponse<T: Codable>: Codable {
    public let response: ResponseBody<T>

    public init(response: ResponseBody<T>) {
        self.response = response
    }
}

public struct ResponseBody<T: Codable>: Codable {
    public let header: ResponseHeader
    public let body: T?

    public init(header: ResponseHeader, body: T?) {
        self.header = header
        self.body = body
    }
}

public struct ResponseHeader: Codable {
    public let resultCode: String
    public let resultMsg: String

    public init(resultCode: String, resultMsg: String) {
        self.resultCode = resultCode
        self.resultMsg = resultMsg
    }
}

public struct ItemBody<T: Codable>: Codable {
    public let items: ItemWrapper<T>
    public let numOfRows: Int
    public let pageNo: Int
    public let totalCount: Int

    public init(items: ItemWrapper<T>, numOfRows: Int, pageNo: Int, totalCount: Int) {
        self.items = items
        self.numOfRows = numOfRows
        self.pageNo = pageNo
        self.totalCount = totalCount
    }
}

/// The API sometimes returns a single item as a dictionary and multiple items as an array.
/// This wrapper handles both cases.
public struct ItemWrapper<T: Codable>: Codable {
    public let item: [T]

    public init(item: [T]) {
        self.item = item
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let singleItem = try? container.decode(T.self, forKey: .item) {
            item = [singleItem]
        } else if let array = try? container.decode([T].self, forKey: .item) {
            item = array
        } else {
            item = []
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(item, forKey: .item)
    }

    private enum CodingKeys: String, CodingKey {
        case item
    }
}

// MARK: - Bus Arrival Info Model

public struct BusArrivalInfo: Codable, Identifiable, Hashable {
    public var id = UUID()
    public let arrprevstationcnt: Int
    public let arrtime: Int
    public let nodeid: String
    public let nodenm: String
    public let routeid: String
    public let routeno: String
    public let routetp: String
    public let vehicletp: String

    public init(
        id: UUID = UUID(),
        arrprevstationcnt: Int,
        arrtime: Int,
        nodeid: String,
        nodenm: String,
        routeid: String,
        routeno: String,
        routetp: String,
        vehicletp: String
    ) {
        self.id = id
        self.arrprevstationcnt = arrprevstationcnt
        self.arrtime = arrtime
        self.nodeid = nodeid
        self.nodenm = nodenm
        self.routeid = routeid
        self.routeno = routeno
        self.routetp = routetp
        self.vehicletp = vehicletp
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: BusArrivalInfo, rhs: BusArrivalInfo) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Bus Stop Info Model

public struct BusStop: Codable, Identifiable, Hashable {
    public let id: UUID
    public let gpslati: Double
    public let gpslong: Double
    public let nodeid: String
    public let nodenm: String
    public let nodeno: Int?

    public init(
        id: UUID = UUID(),
        gpslati: Double,
        gpslong: Double,
        nodeid: String,
        nodenm: String,
        nodeno: Int?
    ) {
        self.id = id
        self.gpslati = gpslati
        self.gpslong = gpslong
        self.nodeid = nodeid
        self.nodenm = nodenm
        self.nodeno = nodeno
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: BusStop, rhs: BusStop) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Bus Route Info Model

public struct BusRoute: Codable, Identifiable, Hashable {
    public var id: UUID
    public let routeid: String
    public let routeno: String
    public let routetp: String
    public let startnodenm: String
    public let endnodenm: String
    public let startvehicletime: String?
    public let endvehicletime: String?

    public init(
        id: UUID = UUID(),
        routeid: String,
        routeno: String,
        routetp: String,
        startnodenm: String,
        endnodenm: String,
        startvehicletime: String?,
        endvehicletime: String?
    ) {
        self.id = id
        self.routeid = routeid
        self.routeno = routeno
        self.routetp = routetp
        self.startnodenm = startnodenm
        self.endnodenm = endnodenm
        self.startvehicletime = startvehicletime
        self.endvehicletime = endvehicletime
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: BusRoute, rhs: BusRoute) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Bus Location Info Model

public struct BusLocation: Codable, Identifiable, Hashable {
    public var id: UUID
    public let gpslati: Double
    public let gpslong: Double
    public let nodeid: String
    public let nodenm: String
    public let routeid: String
    public let vehicleno: String

    public init(
        id: UUID = UUID(),
        gpslati: Double,
        gpslong: Double,
        nodeid: String,
        nodenm: String,
        routeid: String,
        vehicleno: String
    ) {
        self.id = id
        self.gpslati = gpslati
        self.gpslong = gpslong
        self.nodeid = nodeid
        self.nodenm = nodenm
        self.routeid = routeid
        self.vehicleno = vehicleno
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: BusLocation, rhs: BusLocation) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Station-Through-Route Info Model

public struct StationRoute: Codable, Identifiable, Hashable {
    public var id: UUID
    public let routeid: String
    public let routeno: String
    public let routetp: String
    public let startnodenm: String
    public let endnodenm: String

    public init(
        id: UUID = UUID(),
        routeid: String,
        routeno: String,
        routetp: String,
        startnodenm: String,
        endnodenm: String
    ) {
        self.id = id
        self.routeid = routeid
        self.routeno = routeno
        self.routetp = routetp
        self.startnodenm = startnodenm
        self.endnodenm = endnodenm
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: StationRoute, rhs: StationRoute) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Sample Data Extensions

public extension BusArrivalInfo {
    static var sample: BusArrivalInfo {
        BusArrivalInfo(
            arrprevstationcnt: 1,
            arrtime: 91,
            nodeid: "DJB8001793",
            nodenm: "대전역",
            routeid: "DJB30300002",
            routeno: "2",
            routetp: "간선버스",
            vehicletp: "저상버스"
        )
    }
}

public extension BusStop {
    static var sample: BusStop {
        BusStop(gpslati: 36.3325, gpslong: 127.4342, nodeid: "DJB8001793", nodenm: "대전역", nodeno: 101)
    }
}

public extension BusLocation {
    static var sample: BusLocation {
        BusLocation(
            gpslati: 36.3325,
            gpslong: 127.4342,
            nodeid: "DJB8001793",
            nodenm: "대전역",
            routeid: "DJB30300002",
            vehicleno: "대전75자1234"
        )
    }
}

public extension StationRoute {
    static var sample: StationRoute {
        StationRoute(routeid: "DJB30300002", routeno: "2", routetp: "간선버스", startnodenm: "기점", endnodenm: "종점")
    }
}

public extension BusRoute {
    static var sample: BusRoute {
        BusRoute(
            routeid: "DJB30300002",
            routeno: "2",
            routetp: "간선버스",
            startnodenm: "기점",
            endnodenm: "종점",
            startvehicletime: "05:30",
            endvehicletime: "22:00"
        )
    }
}
