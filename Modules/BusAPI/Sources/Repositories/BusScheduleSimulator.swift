import Foundation

enum BusScheduleSimulator {
    struct Route {
        let routeId: String
        let routeNumber: String
        let interval: TimeInterval
    }

    struct Stop {
        let nodeId: String
        let nodeName: String
        let routeStopIndex: Int
    }

    struct Arrival {
        let routeId: String
        let routeNumber: String
        let nodeId: String
        let nodeName: String
        let arrivalTime: Int
        let remainingStops: Int
    }

    private static let routes: [String: Route] = [
        "PHB350000231": Route(routeId: "PHB350000231", routeNumber: "207(기본)", interval: 12 * 60),
        "PHB350000235": Route(routeId: "PHB350000235", routeNumber: "306(기본)", interval: 13 * 60),
    ]

    private static let route207Stops: [(stop: Stop, cumulativeTime: TimeInterval)] = [
        (Stop(nodeId: "PHB350099001", nodeName: "효곡동행정복지센터", routeStopIndex: 0), 0),
        (Stop(nodeId: "PHB350099002", nodeName: "생명공학연구소", routeStopIndex: 1), 45),
        (Stop(nodeId: "PHB350099003", nodeName: "포스텍", routeStopIndex: 2), 110),
        (Stop(nodeId: "PHB350099016", nodeName: "포스텍", routeStopIndex: 3), 180),
        (Stop(nodeId: "PHB350099017", nodeName: "생명공학연구소", routeStopIndex: 4), 260),
    ]

    private static let route306Stops: [(stop: Stop, cumulativeTime: TimeInterval)] = [
        (Stop(nodeId: "PHB350087178", nodeName: "문덕마을회관", routeStopIndex: 0), 0),
        (Stop(nodeId: "PHB350097009", nodeName: "청림초등학교", routeStopIndex: 1), 50),
        (Stop(nodeId: "PHB350000011", nodeName: "대잠사거리", routeStopIndex: 2), 120),
        (Stop(nodeId: "PHB350099013", nodeName: "산책로", routeStopIndex: 3), 180),
        (Stop(nodeId: "PHB350099189", nodeName: "LG빌라", routeStopIndex: 4), 250),
        (Stop(nodeId: "PHB350000017", nodeName: "시청", routeStopIndex: 5), 310),
        (Stop(nodeId: "PHB350087016", nodeName: "구정3리", routeStopIndex: 6), 390),
        (Stop(nodeId: "PHB350099003", nodeName: "포스텍", routeStopIndex: 7), 420),
    ]

    static func calculateArrival(routeId: String, nodeId: String, at currentTime: Date = Date()) -> Arrival? {
        guard let route = routes[routeId] else { return nil }

        let stopsWithTime: [(stop: Stop, cumulativeTime: TimeInterval)]
        switch routeId {
        case "PHB350000231": stopsWithTime = route207Stops
        case "PHB350000235": stopsWithTime = route306Stops
        default: return nil
        }

        guard let targetStopData = stopsWithTime.first(where: { $0.stop.nodeId == nodeId }) else {
            return nil
        }

        let targetStop = targetStopData.stop
        let timeToThisStop = targetStopData.cumulativeTime

        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: currentTime)
        let secondsSinceMidnight = currentTime.timeIntervalSince(midnight)

        let currentCycle = floor(secondsSinceMidnight / route.interval)
        let timeSinceLastDeparture = secondsSinceMidnight - (currentCycle * route.interval)

        let arrivalTimeThisCycle = currentCycle * route.interval + timeToThisStop
        let arrivalTimeNextCycle = (currentCycle + 1) * route.interval + timeToThisStop

        let nextArrivalTime: TimeInterval = if secondsSinceMidnight < arrivalTimeThisCycle {
            arrivalTimeThisCycle
        } else {
            arrivalTimeNextCycle
        }

        let remainingSeconds = Int(max(0, nextArrivalTime - secondsSinceMidnight))

        // 남은 정류장 수는 남은 시간을 정류장 간 평균 시간(60초)으로 나눈 값
        // 최소 1개, 최대 전체 정류장 수
        let averageTimePerStop: TimeInterval = 60
        let estimatedStops = Int(ceil(Double(remainingSeconds) / averageTimePerStop))
        let remainingStops = max(1, min(estimatedStops, stopsWithTime.count))

        return Arrival(
            routeId: route.routeId,
            routeNumber: route.routeNumber,
            nodeId: targetStop.nodeId,
            nodeName: targetStop.nodeName,
            arrivalTime: remainingSeconds,
            remainingStops: remainingStops
        )
    }

    static func calculateArrivals(for nodeId: String, at currentTime: Date = Date()) -> [Arrival] {
        var arrivals: [Arrival] = []
        for (routeId, _) in routes {
            if let arrival = calculateArrival(routeId: routeId, nodeId: nodeId, at: currentTime) {
                arrivals.append(arrival)
            }
        }
        return arrivals.sorted { $0.arrivalTime < $1.arrivalTime }
    }

    static func getRoutesForStop(nodeId: String) -> [Route] {
        var routes: [Route] = []
        if route207Stops.contains(where: { $0.stop.nodeId == nodeId }),
           let route = Self.routes["PHB350000231"]
        {
            routes.append(route)
        }
        if route306Stops.contains(where: { $0.stop.nodeId == nodeId }),
           let route = Self.routes["PHB350000235"]
        {
            routes.append(route)
        }
        return routes
    }
}
