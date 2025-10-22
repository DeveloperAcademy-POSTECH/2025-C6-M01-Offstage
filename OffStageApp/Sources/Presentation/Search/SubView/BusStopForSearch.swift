import Foundation

struct BusStopForSearch: Identifiable {
    let id = UUID()
    /// 정류소이름
    let nodenm: String
    /// 정류소 아이디
    let nodeid: String
    /// 노선번호들
    let routes: [String]
    /// 거리(검색결과일 땐 안보이는)
    let distance: String?
}

extension BusStopForSearch {
    static let sampleBusStop = [
        BusStopForSearch(nodenm: "포항제철공고", nodeid: "299015", routes: ["111", "216"], distance: "559m"),
        BusStopForSearch(nodenm: "포항제철공고", nodeid: "299004", routes: ["111", "216"], distance: "731m"),
        BusStopForSearch(nodenm: "포항성모병원", nodeid: "300019", routes: ["111", "216"], distance: "1.3km"),
    ]
}
