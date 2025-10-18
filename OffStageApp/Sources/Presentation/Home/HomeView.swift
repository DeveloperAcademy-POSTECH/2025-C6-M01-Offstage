import BusAPI
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: Router<AppRoute>

    // Create a sample bus stop info object to pass as a parameter
    private let sampleBusStop = BusStopInfo(
        cityCode: 25,
        nodeId: "DGB7021025800",
        routeId: "DGB30000007000",
        stopName: "경북대학교북문앞",
        routeNo: "719",
        gpsLati: 35.89294,
        gpsLong: 128.61042
    )

    var body: some View {
        VStack(spacing: 16) {
            Text("메인 화면")
                .font(.largeTitle)

            Button("버스 검색으로 이동") {
                router.push(.search(busStopInfo: sampleBusStop))
            }

            Button("버스 정류장으로 이동 (데이터 전달)") {
                router.push(.busstation(busStopInfo: sampleBusStop))
            }

            Button("비전 버스 켜기") {
                router.push(.busvision)
            }

            Button("홈 편집하기") {
                router.push(.homeedit)
            }
        }
        .padding()
        .navigationTitle("Home")
    }
}

#Preview {
    // 미리보기용 Mock Router
    RouterView(router: Router<AppRoute>(root: .home))
}
