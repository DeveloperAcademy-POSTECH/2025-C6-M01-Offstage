import BusAPI
import SwiftData
import SwiftUI

// 더미 모델
// 버스 데이터
@Model
class BusSampleData {
    var id: UUID = UUID()
    var routeNumber: String
    var endnodenm: String
    var arrivalMinutes1: Int
    var arrivalMinutes2: Int
    var stopsAway1: Int
    var stopsAway2: Int
    var stationNumber: String

    init(
        id: UUID = UUID(),
        routeNumber: String,
        endnodenm: String,
        arrivalMinutes1: Int,
        arrivalMinutes2: Int,
        stopsAway1: Int,
        stopsAway2: Int,
        stationNumber: String
    ) {
        self.id = id
        self.routeNumber = routeNumber
        self.endnodenm = endnodenm
        self.arrivalMinutes1 = arrivalMinutes1
        self.arrivalMinutes2 = arrivalMinutes2
        self.stopsAway1 = stopsAway1
        self.stopsAway2 = stopsAway2
        self.stationNumber = stationNumber
    }
}

// 더미 모델
// 정류소 데이터
@Model
class BusStopForHome {
    var id: UUID
    /// 정류소 이름
    var nodenm: String
    /// 정류소 번호
    var nodeno: String
    var nodeId: String
    var cityCode: String
    /// 이 정류장을 지나는 버스들
    var routes: [BusSampleData]

    init(
        id: UUID = UUID(),
        stationName: String,
        stationNumber: String,
        nodeId: String,
        cityCode: String,
        busRoutes: [BusSampleData]
    ) {
        self.id = id
        nodenm = stationName
        nodeno = stationNumber
        self.nodeId = nodeId
        self.cityCode = cityCode
        routes = busRoutes
    }
}

// 더미 데이터
let busSampleData: [BusSampleData] = [
    BusSampleData(
        id: UUID(),
        routeNumber: "111",
        endnodenm: "시청방면",
        arrivalMinutes1: 480,
        arrivalMinutes2: 1320,
        stopsAway1: 2,
        stopsAway2: 13,
        stationNumber: "12341234"
    ),
    BusSampleData(
        id: UUID(),
        routeNumber: "112",
        endnodenm: "시청방면",
        arrivalMinutes1: 470,
        arrivalMinutes2: 1310,
        stopsAway1: 1,
        stopsAway2: 12,
        stationNumber: "12341234"
    ),
    BusSampleData(
        id: UUID(),
        routeNumber: "212",
        endnodenm: "효자시장방면",
        arrivalMinutes1: 470,
        arrivalMinutes2: 1310,
        stopsAway1: 1,
        stopsAway2: 12,
        stationNumber: "12312312"
    ),
    BusSampleData(
        id: UUID(),
        routeNumber: "212",
        endnodenm: "효자시장방면",
        arrivalMinutes1: 470,
        arrivalMinutes2: 1310,
        stopsAway1: 1,
        stopsAway2: 12,
        stationNumber: "12312312"
    ),
]
// 더미 데이터
let busStationData: [BusStopForHome] = [
    BusStopForHome(
        id: UUID(),
        stationName: "포항공과대학교",
        stationNumber: "37710",
        nodeId: "PHB8000123",
        cityCode: "37010",
        busRoutes: busSampleData.filter { $0.stationNumber == "12341234" }
    ),
    BusStopForHome(
        id: UUID(),
        stationName: "효자시장",
        stationNumber: "37734",
        nodeId: "PHB8000124",
        cityCode: "37010",
        busRoutes: busSampleData.filter { $0.stationNumber == "12312312" }
    ),
]

struct HomeView: View {
    @EnvironmentObject var router: Router<AppRoute>

    /// 숏컷 진입을 위한 더미 데이터. 추후 숏컷 삭제 시 함께 삭제
    private let sampleBusStop = BusStopInfo(
        cityCode: 31020,
        nodeId: "GGB204000163",
        routeId: "GGB204000163",
        stopName: "판교",
        routeNo: "102",
        gpsLati: 37.394726159,
        gpsLong: 127.1112090472
    )

    @State private var searchText = ""
    @State private var activatedNodeID: String = ""
    /// 홈화면에 필요한 데이터
    @State private var busStationData: [BusStopForHome]?

    var body: some View {
        VStack {
            VStack {
                Button {
                    // 검색 페이지로 이동
                    router.push(.search)
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        Text("버스 노선, 정류장 검색")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding()
                .background(.gray.opacity(0.1))

                ScrollView {
                    Text("홈")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .center))
                        .padding(.horizontal)

                    if let busStationData {
                        ForEach(busStationData) { station in
                            BusStationCardSubView(
                                stationName: station.nodenm,
                                stationNumber: station.nodeno,
                                nodeId: station.nodeId,
                                cityCode: station.cityCode
                            )
                            .padding(.horizontal)
                        }
                        .padding(.vertical)

                        Button("편집") {
                            router.push(.homeedit)
                        }
                        .padding(.bottom)
                    } else {
                        Text("저장된 내역이 없습니다.")
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                            .padding(.bottom)
                        Text("자주 이용하는 버스를 추가해 주세요.")
                            .foregroundColor(.gray)
                            .padding(.bottom, 30)

                        Button {
                            router.push(.search)
                        } label: {
                            Text("나의 버스 추가하기")
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(20)
                        }

                        Spacer()
                    }

                    Divider()
                    Button("TestView로 이동 (데이터 전달)") {
                        router.push(.test(busStopInfo: sampleBusStop))
                    }
                    Button("비전 버스 켜기") {
                        router.push(.busvision(routeToDetect: ["1142"]))
                    }
                }
            }
        }.onAppear {
            fetchData()
        }
    }
}

extension HomeView {
    // TODO: 추후 VM에서 API 호출로 데이터 채우기
    private func fetchData() {
        busStationData = [
            BusStopForHome(
                id: UUID(),
                stationName: "포항공과대학교",
                stationNumber: "37710",
                nodeId: "PHB8000123",
                cityCode: "37010",
                busRoutes: busSampleData.filter {
                    $0.stationNumber == "12341234"
                }
            ),
            BusStopForHome(
                id: UUID(),
                stationName: "효자시장",
                stationNumber: "37734",
                nodeId: "PHB8000124",
                cityCode: "37010",
                busRoutes: busSampleData.filter {
                    $0.stationNumber == "12312312"
                }
            ),
        ]
    }
}

#Preview {
    // 미리보기용 Mock Router
    RouterView(router: Router<AppRoute>(root: .home))
}
