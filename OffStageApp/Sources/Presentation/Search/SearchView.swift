import BusAPI
import SwiftUI

struct SearchView: View {
    @EnvironmentObject var router: Router<AppRoute>
    let busStopInfo: BusStopInfo

    var body: some View {
        VStack(spacing: 16) {
            Text("버스 검색 화면")
                .font(.largeTitle)

            Text("전달받은 정류소: \(busStopInfo.stopName)")

            Button("버스 정류장 상세 보기") {
                router.push(.busstation(busStopInfo: busStopInfo))
            }

            Button("이전 화면으로 돌아가기 (pop)") {
                router.pop()
            }

            Button("홈으로 돌아가기 (popToRoot)") {
                router.popToRoot()
            }
        }
        .padding()
        .navigationTitle("Bus Search")
    }
}

#Preview {
    let sampleBusStop = BusStopInfo(
        cityCode: 25,
        nodeId: "DGB7021025800",
        routeId: "DGB30000007000",
        stopName: "경북대학교북문앞",
        routeNo: "719",
        gpsLati: 35.89294,
        gpsLong: 128.61042
    )
    // 미리보기용 Mock Router
    return RouterView(router: Router<AppRoute>(root: .search(busStopInfo: sampleBusStop)))
}
