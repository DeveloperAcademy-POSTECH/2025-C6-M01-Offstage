
import Foundation

/// 정류소 정보를 담는 모델
struct BusStopInfo: Codable, Hashable {
    /// 도시 코드
    let cityCode: Int
    /// 정류소 ID
    let nodeId: String
    /// 노선 ID
    let routeId: String
    /// 정류소 이름
    let stopName: String
    /// 노선 번호
    let routeNo: String
    /// 위도
    let gpsLati: Double
    /// 경도
    let gpsLong: Double
}
