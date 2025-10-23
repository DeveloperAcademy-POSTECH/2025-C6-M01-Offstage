import Foundation
import SwiftData

@Model
final class Favorite {
    /// cityCode, nodeId, routeId 를 조합한 즐겨찾기 고유 ID
    @Attribute(.unique) var id: String
    /// 도시코드
    let cityCode: String
    /// 정류소 ID
    let nodeId: String
    /// 정류소 번호
    let nodeNo: String?
    /// 노선 ID
    let routeId: String
    /// 정류소 이름
    let nodeName: String
    /// 노선 번호
    let routeNo: String
    /// 노선 방향
    let direction: String

    init(
        cityCode: String,
        nodeId: String,
        nodeNo: String?,
        routeId: String,
        nodeName: String,
        routeNo: String,
        direction: String
    ) {
        id = "\(cityCode)-\(nodeId)-\(routeId)"
        self.cityCode = cityCode
        self.nodeId = nodeId
        self.nodeNo = nodeNo
        self.routeId = routeId
        self.nodeName = nodeName
        self.routeNo = routeNo
        self.direction = direction
    }
}
