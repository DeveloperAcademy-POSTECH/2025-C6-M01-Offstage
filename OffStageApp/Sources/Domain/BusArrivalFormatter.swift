import BusAPI
import Foundation

enum BusArrivalFormatter {
    static func formatArrivalTime(_ seconds: Int?) -> String {
        guard let seconds else { return String(localized: "busArrival.a11y.format.noInfo") }
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        if minutes >= 1 {
            return String(
                format: String(localized: "busArrival.a11y.format.minutesSeconds"),
                String(minutes), String(remainingSeconds)
            )
        }

        return String(localized: "busArrival.a11y.format.soon")
    }

    static func formatRemainingStops(_ remainingStops: Int) -> String {
        if remainingStops > 1 {
            String(
                format: String(localized: "busArrival.a11y.format.stopsAway"),
                String(remainingStops)
            )
        } else {
            String(localized: "busArrival.a11y.format.previousStop")
        }
    }

    static func generateArrivalLabel(
        arrival: BusArrival,
        busRoute: BusRoute,
        currentEstimatedArrivalTime: Int?
    ) -> String {
        let routeNum = String(
            format: String(localized: "busArrival.a11y.format.routeNumber"),
            busRoute.routeNumber
        )
        let formattedArrivalTime = formatArrivalTime(currentEstimatedArrivalTime)
        let formattedStops = formatRemainingStops(arrival.remainingStopCount ?? 0)

        let status = String(localized: "busArrival.a11y.format.arriving")

        return "\(routeNum), \(formattedArrivalTime) \(status), \(formattedStops)"
    }

    static func formatSimpleArrivalInfo(remainingStops: Int?, arrivalTime: Int?) -> String {
        if let remainingStops, let arrivalTime {
            let minutes = arrivalTime / 60
            return "\(remainingStops)번째 전 · 약 \(minutes)분 후 도착"
        } else if let remainingStops {
            return "\(remainingStops)번째 전"
        } else if let arrivalTime {
            let minutes = arrivalTime / 60
            return "약 \(minutes)분 후 도착"
        } else {
            return "도착 예정"
        }
    }
}
