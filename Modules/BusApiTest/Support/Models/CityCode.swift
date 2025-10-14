import Foundation

/// 도시 코드 정보를 담는 항목입니다.
struct CityCode: Decodable {
    /// 도시 코드입니다.
    let citycode: String?
    /// 도시 이름입니다.
    let cityname: String?

    /// 로그 출력용 요약 문자열입니다.
    var debugSummary: String {
        "도시: \(cityname ?? "-")(\(citycode ?? "-"))"
    }
}
