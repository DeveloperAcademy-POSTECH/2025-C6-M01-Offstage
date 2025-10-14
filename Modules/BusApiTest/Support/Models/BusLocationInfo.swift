import Foundation

/// 노선별 버스 실시간 위치 정보 항목입니다.
struct BusLocationInfo: Decodable {
    /// 차량 번호입니다.
    let vehicleno: String?
    /// 위도 값입니다.
    let gpslati: Double?
    /// 경도 값입니다.
    let gpslong: Double?
    /// 노선 ID입니다.
    let routeId: String?
    /// 남은 정류장 수입니다.
    let remainStop: Int?
    /// 노선 이름 또는 번호입니다.
    let routenm: String?
    /// 정류장 순번입니다.
    let nodeord: String?
    /// 정류장 ID입니다.
    let nodeid: String?
    /// 정류장 이름입니다.
    let nodenm: String?

    enum CodingKeys: String, CodingKey {
        case vehicleno
        case gpslati
        case gpslong
        case routeId
        case remainStop = "remain_stop"
        case routenm
        case nodeord
        case nodeid
        case nodenm
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decode(String.self, forKey: .vehicleno) {
            vehicleno = value
        } else if let intValue = try? container.decode(Int.self, forKey: .vehicleno) {
            vehicleno = String(intValue)
        } else {
            vehicleno = nil
        }

        if let value = try? container.decode(String.self, forKey: .gpslati) {
            gpslati = Double(value)
        } else {
            gpslati = try? container.decode(Double.self, forKey: .gpslati)
        }

        if let value = try? container.decode(String.self, forKey: .gpslong) {
            gpslong = Double(value)
        } else {
            gpslong = try? container.decode(Double.self, forKey: .gpslong)
        }

        routeId = try? container.decode(String.self, forKey: .routeId)
        remainStop = try? container.decode(Int.self, forKey: .remainStop)

        if let value = try? container.decode(String.self, forKey: .nodeord) {
            nodeord = value
        } else if let intValue = try? container.decode(Int.self, forKey: .nodeord) {
            nodeord = String(intValue)
        } else {
            nodeord = nil
        }

        if let value = try? container.decode(String.self, forKey: .routenm) {
            routenm = value
        } else if let intValue = try? container.decode(Int.self, forKey: .routenm) {
            routenm = String(intValue)
        } else {
            routenm = nil
        }

        nodeid = try? container.decode(String.self, forKey: .nodeid)
        nodenm = try? container.decode(String.self, forKey: .nodenm)
    }

    /// 로그 출력용 요약 문자열입니다.
    var debugSummary: String {
        let latitude = gpslati.map { String($0) } ?? "-"
        let longitude = gpslong.map { String($0) } ?? "-"
        return [
            "차량번호: \(vehicleno ?? "-")",
            "위치: (\(latitude), \(longitude))",
            "남은정류장: \(remainStop.map(String.init) ?? "-")",
        ].joined(separator: ", ")
    }
}
