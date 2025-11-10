import Foundation

enum BusDetectStatus: String {
    case unDetected
    case notMine
    case mineDetected
}

extension BusDetectStatus {
    var text: String {
        switch self {
        case .unDetected:
            "버스 인식 중"
        case .notMine:
            "다른 번호의 버스입니다."
        case .mineDetected:
            "hello, bus!"
        }
    }
}
