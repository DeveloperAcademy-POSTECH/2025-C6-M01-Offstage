import Foundation

/// 정류소 기준 버스 도착 정보 항목입니다.
struct BusArrivalInfo: Decodable {
    /// 차량 종류입니다. (예: 저상버스)
    let vehicletp: String?
    /// 노선 ID입니다.
    let routeid: String?
    /// 정류장 ID입니다.
    let nodeid: String?
    /// 정류장 이름입니다.
    let nodenm: String?
    /// 노선 종류입니다. (예: 간선, 지선)
    let routetp: String?
    /// 노선 번호입니다.
    let routeno: String?
    /// 이전 정류장 수입니다.
    let arrprevstationcnt: Int?
    /// 남은 도착 시간(초)입니다.
    let arrtime: Int?

    /// 로그 출력용 요약 문자열입니다.
    var debugSummary: String {
        [
            "노선: \(routeno ?? "-")",
            "정류장: \(nodenm ?? "-")",
            "도착까지: \(arrtime.map { "\($0)s" } ?? "-")",
        ].joined(separator: ", ")
    }
}
