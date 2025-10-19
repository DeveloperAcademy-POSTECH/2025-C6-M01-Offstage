import Foundation
import Moya

public protocol BusAPITarget: TargetType {
    var serviceKey: String { get }
}

public extension BusAPITarget {
    var baseURL: URL { URL(string: "https://apis.data.go.kr/1613000")! }
    var method: Moya.Method { .get }
    var headers: [String: String]? { ["Content-type": "application/json"] }
}
