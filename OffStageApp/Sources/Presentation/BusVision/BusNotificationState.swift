import Foundation

enum BusNotificationState {
    /// 버스 곧 도착 감지 대기
    case waitingForArrival
    /// 곧 도착 알림 완료
    case arrivalAlertSent
}
