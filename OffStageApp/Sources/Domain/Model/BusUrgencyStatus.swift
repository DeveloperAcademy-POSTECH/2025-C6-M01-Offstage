import Foundation

public enum BusUrgencyStatus: String {
    case fiveOrMoreStops = "5개 정류장 이상"
    case threeOrFourStops = "3-4개 정류장 전"
    case twoStops = "2개 정류장 전"
    case oneStop = "1개 정류장 전"
    case arrived = "곧도착"
    case notApplicable = "해당 없음" // 조건에 맞지 않을 때

    public var refreshIntervalSeconds: UInt64 {
        switch self {
        case .fiveOrMoreStops:
            90
        case .threeOrFourStops:
            60
        case .twoStops:
            30
        case .oneStop:
            15
        case .arrived:
            10
        case .notApplicable:
            15 // Default for no arrival info
        }
    }

    public static func status(for estimatedTimeInSeconds: Int?, remainingStops: Int?) -> BusUrgencyStatus {
        guard let remainingStops, remainingStops >= 0 else {
            return .notApplicable
        }

        var status: BusUrgencyStatus = .notApplicable

        if remainingStops >= 5 {
            status = .fiveOrMoreStops
        } else if remainingStops >= 3 {
            status = .threeOrFourStops
        } else if remainingStops == 2 {
            status = .twoStops
        } else if remainingStops == 1 {
            status = .oneStop
        } else if remainingStops == 0 {
            status = .arrived
        }
        if let estimatedTime = estimatedTimeInSeconds, estimatedTime < 60 {
            status = .arrived
        }
        return status
    }
}
