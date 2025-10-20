import Foundation

/// 정류소 기본 정보를 담는 항목입니다.
struct BusStopInfo: Decodable {
    /// 정류장 ID입니다.
    let nodeid: String?
    /// 정류장 이름입니다.
    let nodenm: String?
    /// 위도 값입니다.
    let latitude: Double?
    /// 경도 값입니다.
    let longitude: Double?
    /// 노선 ID입니다.
    let routeid: String?
    /// 노선 유형입니다.
    let routetp: String?
    /// 정류장 번호입니다.
    let nodeno: String?
    /// 노선 번호입니다.
    let routeno: String?

    enum CodingKeys: String, CodingKey {
        case nodeid
        case nodenm
        case latitude = "gpslati"
        case longitude = "gpslong"
        case routeid
        case routetp
        case nodeno
        case routeno
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nodeid = try? container.decode(String.self, forKey: .nodeid)
        nodenm = try? container.decode(String.self, forKey: .nodenm)

        if let value = try? container.decode(String.self, forKey: .latitude) {
            latitude = Double(value)
        } else {
            latitude = try? container.decode(Double.self, forKey: .latitude)
        }

        if let value = try? container.decode(String.self, forKey: .longitude) {
            longitude = Double(value)
        } else {
            longitude = try? container.decode(Double.self, forKey: .longitude)
        }

        routeid = try? container.decode(String.self, forKey: .routeid)
        routetp = try? container.decode(String.self, forKey: .routetp)

        if let value = try? container.decode(String.self, forKey: .nodeno) {
            nodeno = value
        } else if let intValue = try? container.decode(Int.self, forKey: .nodeno) {
            nodeno = String(intValue)
        } else {
            nodeno = nil
        }

        if let value = try? container.decode(String.self, forKey: .routeno) {
            routeno = value
        } else if let intValue = try? container.decode(Int.self, forKey: .routeno) {
            routeno = String(intValue)
        } else {
            routeno = nil
        }
    }

    /// 로그 출력용 요약 문자열입니다.
    var debugSummary: String {
        [
            "정류장: \(nodenm ?? "-")",
            "ID: \(nodeid ?? "-")",
            "좌표: (\(latitude.map { String($0) } ?? "-"), \(longitude.map { String($0) } ?? "-"))",
        ].joined(separator: ", ")
    }
}
