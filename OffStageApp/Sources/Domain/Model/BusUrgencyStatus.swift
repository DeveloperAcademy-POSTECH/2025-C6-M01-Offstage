import Foundation

/// 버스 도착 긴급도 상태
///
/// **관리 항목:**
/// - API 갱신 주기 (refreshIntervalSeconds)
/// - `버스 인식하기` 버튼 활성화 상태
///
/// **향후 고려사항:**
/// - 남은 시간 60초 미만: "곧 도착" 문구 표시
/// - 남은 정류장 1개 이하: "전 정류장에서 출발했습니다." 문구 표시
/// - 현재는 `OffStageApp/Sources/Presentation/Home/SubView/BusArrivalView.swift`에서 관리 중
public enum BusUrgencyStatus: String {
    case fiveOrMoreStops = "5개 정류장 이상"
    case threeOrFourStops = "3-4개 정류장 전"
    case arrived = "곧도착"
    case notApplicable = "해당 없음" // 조건에 맞지 않을 때

    /// API 갱신 주기 (초 단위)
    public var refreshIntervalSeconds: UInt64 {
        switch self {
        case .fiveOrMoreStops:
            60
        case .threeOrFourStops:
            30
        case .arrived:
            15
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
        } else if remainingStops <= 2 {
            status = .arrived
        }
        if let estimatedTime = estimatedTimeInSeconds, estimatedTime < 120 {
            status = .arrived
        }
        return status
    }
}
