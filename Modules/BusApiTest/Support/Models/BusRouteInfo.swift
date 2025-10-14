import Foundation

/// 노선 기본 정보를 담는 항목입니다.
struct BusRouteInfo: Decodable {
    /// 노선 ID입니다.
    let routeid: String?
    /// 노선 번호입니다.
    let routeno: String?
    /// 노선 유형입니다. (예: 간선)
    let routetp: String?
    /// 운수 회사 이름입니다.
    let companyNm: String?
    /// 기점 정류장 이름입니다.
    let startnodenm: String?
    /// 종점 정류장 이름입니다.
    let endnodenm: String?
    /// 첫 차 출발 시각입니다.
    let startvehicletime: String?
    /// 막차 종료 시각입니다.
    let endvehicletime: String?
    /// 현재 정류장 이름입니다.
    let nodenm: String?
    /// 현재 정류장 ID입니다.
    let nodeid: String?
    /// 위도 값입니다.
    let gpslati: Double?
    /// 경도 값입니다.
    let gpslong: Double?
    /// 정류장 순번입니다.
    let nodeord: String?

    enum CodingKeys: String, CodingKey {
        case routeid
        case routeno
        case routetp
        case companyNm
        case startnodenm
        case endnodenm
        case startvehicletime
        case endvehicletime
        case nodenm
        case nodeid
        case gpslati
        case gpslong
        case nodeord
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        routeid = try? container.decode(String.self, forKey: .routeid)

        if let value = try? container.decode(String.self, forKey: .routeno) {
            routeno = value
        } else if let intValue = try? container.decode(Int.self, forKey: .routeno) {
            routeno = String(intValue)
        } else {
            routeno = nil
        }

        routetp = try? container.decode(String.self, forKey: .routetp)
        companyNm = try? container.decode(String.self, forKey: .companyNm)
        startnodenm = try? container.decode(String.self, forKey: .startnodenm)
        endnodenm = try? container.decode(String.self, forKey: .endnodenm)

        if let value = try? container.decode(String.self, forKey: .startvehicletime) {
            startvehicletime = value
        } else if let intValue = try? container.decode(Int.self, forKey: .startvehicletime) {
            startvehicletime = String(intValue)
        } else {
            startvehicletime = nil
        }

        if let value = try? container.decode(String.self, forKey: .endvehicletime) {
            endvehicletime = value
        } else if let intValue = try? container.decode(Int.self, forKey: .endvehicletime) {
            endvehicletime = String(intValue)
        } else {
            endvehicletime = nil
        }

        nodenm = try? container.decode(String.self, forKey: .nodenm)
        nodeid = try? container.decode(String.self, forKey: .nodeid)

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

        if let value = try? container.decode(String.self, forKey: .nodeord) {
            nodeord = value
        } else if let intValue = try? container.decode(Int.self, forKey: .nodeord) {
            nodeord = String(intValue)
        } else {
            nodeord = nil
        }
    }

    /// 로그 출력용 요약 문자열입니다.
    var debugSummary: String {
        [
            "노선: \(routeno ?? "-")",
            "기점: \(startnodenm ?? "-")",
            "종점: \(endnodenm ?? "-")",
        ].joined(separator: ", ")
    }
}
