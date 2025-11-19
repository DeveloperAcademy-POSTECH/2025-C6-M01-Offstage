import Foundation

/// 앱 전체에서 사용하는 새로고침 간격을 정의합니다.
enum RefreshInterval {
    /// 버스 도착 정보 기본 새로고침 간격 (30초)
    static let busArrival: UInt64 = 30_000_000_000

    /// 위치 정보 새로고침 간격 (15초)
    static let location: UInt64 = 15_000_000_000

    /// 일반적인 데이터 새로고침 간격 (10초)
    static let `default`: UInt64 = 10_000_000_000

    /// 커스텀 초 단위를 나노초로 변환
    /// - Parameter seconds: 초 단위 시간
    /// - Returns: 나노초 단위 시간
    static func seconds(_ seconds: Int) -> UInt64 {
        UInt64(seconds) * 1_000_000_000
    }

    /// 커스텀 밀리초 단위를 나노초로 변환
    /// - Parameter milliseconds: 밀리초 단위 시간
    /// - Returns: 나노초 단위 시간
    static func milliseconds(_ milliseconds: Int) -> UInt64 {
        UInt64(milliseconds) * 1_000_000
    }

    /// 버스 도착 예정 시간에 따라 동적으로 새로고침 간격을 계산합니다.
    /// - Parameters:
    ///   - estimatedArrivalTime: 도착 예정 시간 (초 단위)
    ///   - remainingStops: 남은 정류장 수
    /// - Returns: 나노초 단위 새로고침 간격
    ///
    /// 알고리즘:
    /// - 10분(600초) 이상: 30초마다 새로고침
    /// - 5~10분: 20초마다 새로고침
    /// - 3~5분: 15초마다 새로고침
    /// - 1~3분: 10초마다 새로고침
    /// - 1분 이하: 5초마다 새로고침
    static func forBusArrival(estimatedArrivalTime: Int?, remainingStops _: Int?) -> UInt64 {
        guard let arrivalTime = estimatedArrivalTime, arrivalTime > 0 else {
            // 도착 시간 정보가 없으면 기본 간격 사용
            return busArrival
        }

        switch arrivalTime {
        case 600...:
            // 10분 이상
            return seconds(30)
        case 300 ..< 600:
            // 5~10분
            return seconds(20)
        case 180 ..< 300:
            // 3~5분
            return seconds(15)
        case 60 ..< 180:
            // 1~3분
            return seconds(10)
        default:
            // 1분 이하
            return seconds(5)
        }
    }
}
