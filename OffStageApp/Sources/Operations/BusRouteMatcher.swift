import BusAPI
import Foundation

enum BusRouteMatch {
    case exact(BusRoute)
    case partial([BusRoute])
    case fuzzy(BusRoute)
    case none(String)
}

struct BusRouteMatcher {
    private let cleanedRouteMap: [String: BusRoute]

    init(busRoutes: [BusRoute]) {
        cleanedRouteMap = Dictionary(
            busRoutes.map { ($0.routeNumber.removeParenthesesContent(), $0) },
            uniquingKeysWith: { first, _ in first }
        )
    }

    func process(transcript: String) -> BusRouteMatch {
        // 1. 전처리: STT 입력값 정규화
        let normalizedSTT = transcript.normalizeBusNumber()
        print("Normalized STT: \(normalizedSTT)")

        // 2. 전략 1: 완전 일치 (Exact Match)
        if let matchedRoute = cleanedRouteMap[normalizedSTT] {
            return .exact(matchedRoute)
        }

        // 3. 전략 2: 접두사 일치 (Prefix Match)
        let prefixMatches = cleanedRouteMap.keys.filter { $0.starts(with: normalizedSTT) }

        if prefixMatches.count == 1, let key = prefixMatches.first, let matchedRoute = cleanedRouteMap[key] {
            return .exact(matchedRoute)
        } else if prefixMatches.count > 1 {
            let matchedRoutes = prefixMatches.compactMap { cleanedRouteMap[$0] }
            return .partial(matchedRoutes)
        }

        // 4. 전략 3: 유사도(Fuzzy) 매칭
        var bestMatch: (route: BusRoute, distance: Int)? = nil
        let threshold = 2 // 임계값

        for (key, route) in cleanedRouteMap {
            let distance = normalizedSTT.levenshteinDistance(to: key)

            if bestMatch == nil || distance < bestMatch!.distance {
                bestMatch = (route, distance)
            }
        }

        if let bestMatch, bestMatch.distance <= threshold {
            return .fuzzy(bestMatch.route)
        }

        // 5. 전략 4: 일치 항목 없음 (Fallback)
        return .none(normalizedSTT)
    }
}
