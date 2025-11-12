import Foundation

public enum BusUrgencyStatus: String {
    case relaxed = "여유롭게 기다리세요" // 8분 이상
    case slightlyRelaxed = "조금 여유 있어요" // 5분 초과 8분 미만
    case prepare = "슬슬 준비하세요" // 5분 이하
    case morePrepare = "슬슬 짐 챙기세요" // 3분 미만
    case evenMorePrepare = "거의 다 왔어요" // 2분 미만
    case readyToBoard = "카메라 켜세요" // 1분 미만
    case notApplicable = "해당 없음" // 조건에 맞지 않을 때

    public var refreshIntervalSeconds: UInt64 {
        switch self {
        case .relaxed:
            90
        case .slightlyRelaxed:
            60
        case .prepare:
            45
        case .morePrepare:
            20
        case .evenMorePrepare:
            10
        case .readyToBoard:
            5
        case .notApplicable:
            15 // Default for no arrival info
        }
    }

    public static func status(for estimatedTimeInSeconds: Int?, remainingStops: Int?) -> BusUrgencyStatus {
        guard let remainingStops,
              let estimatedTime = estimatedTimeInSeconds
        else {
            return .notApplicable
        }

        // 긴급도 상태는 버스가 2정거장 이내에 있을 때만 활성화됩니다.
        guard remainingStops <= 2 else {
            return .notApplicable
        }

        // 남은 시간에 따라 긴급도 상태를 결정합니다.
        if estimatedTime < 1 * 60 { // 1분 미만
            return .readyToBoard
        } else if estimatedTime < 2 * 60 { // 1분 이상 2분 미만
            return .evenMorePrepare
        } else if estimatedTime < 3 * 60 { // 2분 이상 3분 미만
            return .morePrepare
        } else if estimatedTime <= 5 * 60 { // 3분 이상 5분 이하
            return .prepare
        } else if estimatedTime < 8 * 60 { // 5분 초과 8분 미만
            return .slightlyRelaxed
        } else if estimatedTime >= 8 * 60 { // 8분 이상
            return .relaxed
        }

        return .notApplicable // 모든 조건에 해당하지 않을 경우
    }
}
