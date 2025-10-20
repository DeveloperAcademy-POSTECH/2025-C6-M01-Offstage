import BusAPI
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: Router<AppRoute>

    // Create a sample bus stop info object to pass as a parameter
    private let sampleBusStop = BusStopInfo(
        cityCode: 31020,
        nodeId: "GGB204000163",
        routeId: "GGB204000163",
        stopName: "판교",
        routeNo: "102",
        gpsLati: 37.394726159,
        gpsLong: 127.1112090472
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

            Button("TestView로 이동 (데이터 전달)") {
                router.push(.test(busStopInfo: sampleBusStop))
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
