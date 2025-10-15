import Foundation

// MARK: - Generic API Response Wrappers

struct ApiResponse<T: Codable>: Codable {
    let response: ResponseBody<T>
}

struct ResponseBody<T: Codable>: Codable {
    let header: ResponseHeader
    let body: T?
}

struct ResponseHeader: Codable {
    let resultCode: String
    let resultMsg: String
}

struct ItemBody<T: Codable>: Codable {
    let items: ItemWrapper<T>
    let numOfRows: Int
    let pageNo: Int
    let totalCount: Int
}

// The API sometimes returns a single item as a dictionary and multiple items as an array.
// This wrapper handles both cases.
struct ItemWrapper<T: Codable>: Codable {
    let item: [T]

    init(item: [T]) {
        self.item = item
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let singleItem = try? container.decode(T.self) {
            item = [singleItem]
        } else if let array = try? container.decode([T].self) {
            item = array
        } else {
            item = []
        }
    }
}

// MARK: - Bus Arrival Info Model

struct BusArrivalInfo: Codable, Identifiable, Hashable {
    var id = UUID()
    let arrprevstationcnt: Int
    let arrtime: Int
    let nodeid: String
    let nodenm: String
    let routeid: String
    let routeno: String
    let routetp: String
    let vehicletp: String

    enum CodingKeys: String, CodingKey {
        case arrprevstationcnt, arrtime, nodeid, nodenm, routeid, routeno, routetp, vehicletp
    }

    // Add Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: BusArrivalInfo, rhs: BusArrivalInfo) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Bus Stop Info Model

struct BusStop: Codable, Identifiable, Hashable {
    let id = UUID()
    let gpslati: Double
    let gpslong: Double
    let nodeid: String
    let nodenm: String
    let nodeno: Int?

    enum CodingKeys: String, CodingKey {
        case gpslati, gpslong, nodeid, nodenm, nodeno
    }

    // Add Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: BusStop, rhs: BusStop) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Bus Route Info Model

struct BusRoute: Codable, Identifiable, Hashable {
    var id = UUID()
    let routeid: String
    let routeno: String
    let routetp: String
    let startnodenm: String
    let endnodenm: String
    let startvehicletime: String? // Assuming string format like "05:30"
    let endvehicletime: String? // Assuming string format like "22:00"

    enum CodingKeys: String, CodingKey {
        case routeid, routeno, routetp, startnodenm, endnodenm, startvehicletime, endvehicletime
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: BusRoute, rhs: BusRoute) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Bus Location Info Model

struct BusLocation: Codable, Identifiable, Hashable {
    var id = UUID()
    let gpslati: Double
    let gpslong: Double
    let nodeid: String
    let nodenm: String
    let routeid: String
    let vehicleno: String

    enum CodingKeys: String, CodingKey {
        case gpslati, gpslong, nodeid, nodenm, routeid, vehicleno
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: BusLocation, rhs: BusLocation) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Station-Through-Route Info Model

struct StationRoute: Codable, Identifiable, Hashable {
    var id = UUID()
    let routeid: String
    let routeno: String
    let routetp: String
    let startnodenm: String
    let endnodenm: String

    enum CodingKeys: String, CodingKey {
        case routeid, routeno, routetp, startnodenm, endnodenm
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: StationRoute, rhs: StationRoute) -> Bool {
        lhs.id == rhs.id
    }
}
