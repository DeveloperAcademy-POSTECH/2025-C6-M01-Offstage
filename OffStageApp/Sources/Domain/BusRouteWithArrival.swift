import BusAPI
import Foundation

struct BusRouteWithArrival: Identifiable, Equatable {
    let id: String
    let route: BusRoute
    let arrival: BusArrival?

    init(route: BusRoute, arrival: BusArrival?) {
        id = route.id
        self.route = route
        self.arrival = arrival
    }

    static func == (lhs: BusRouteWithArrival, rhs: BusRouteWithArrival) -> Bool {
        lhs.id == rhs.id &&
            lhs.route == rhs.route &&
            lhs.arrival == rhs.arrival
    }
}
