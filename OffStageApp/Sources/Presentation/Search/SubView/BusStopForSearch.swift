import Foundation

struct BusStopForSearch: Identifiable {
    let id = UUID()
    /// 정류소이름
    let nodenm: String
    /// 정류소 번호
    /// nodeid는 api 통신을 위해 사용하는 값이며, nodeno가 user가 이해하는 값 입니다. App 내부에서는 사용하지 않습니다.
    let nodeno: String?
    /// 노선번호들
    let routes: [String]
    /// 거리(검색결과일 땐 안보이는)
    let distance: String?
}

extension BusStopForSearch {
    static let sampleBusStop = [
        BusStopForSearch(nodenm: "포항제철공고", nodeno: "299015", routes: ["111", "216"], distance: "559m"),
        BusStopForSearch(nodenm: "포항제철공고", nodeno: "299004", routes: ["111", "216"], distance: "731m"),
        BusStopForSearch(nodenm: "포항성모병원", nodeno: "300019", routes: ["111", "216"], distance: "1.3km"),
    ]
}
