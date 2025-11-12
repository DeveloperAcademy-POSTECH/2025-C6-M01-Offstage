import Foundation

enum BusDetectStatus {
    /// 인식중: 아무런 버스도 인식 안된 상태
    case unDetected
    /// 내가 탈 버스가 아닌 다른 버스가 인식된 상태
    case notMine
    /// 내가 탈 버스가 인식된 상태(내 버스의 노선번호를 가지고 있음)
    case mineDetected(routeNum: String)
}
