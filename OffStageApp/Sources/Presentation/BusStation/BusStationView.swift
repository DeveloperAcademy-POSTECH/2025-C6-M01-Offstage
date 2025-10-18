import SwiftUI

struct BusStationView: View {
    @EnvironmentObject var router: Router<AppRoute>
    let busStopInfo: BusStopInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(busStopInfo.stopName)
                .font(.largeTitle)

            HStack {
                Text(busStopInfo.routeNo)
                Spacer()
                Text("\(busStopInfo.cityCode)")
            }
            .font(.headline)

            Text("정류소 ID: \(busStopInfo.nodeId)")
            Text("노선 ID: \(busStopInfo.routeId)")
            Text("좌표: (\(busStopInfo.gpsLati), \(busStopInfo.gpsLong))")

            Spacer()

            Button("이전 화면으로 돌아가기 (pop)") {
                router.pop()
            }

            Button("홈으로 돌아가기 (popToRoot)") {
                router.popToRoot()
            }
        }
        .padding()
        .navigationTitle(busStopInfo.stopName)
    }
}

#Preview {
    let mockBusStop = BusStopInfo(
        cityCode: 25,
        nodeId: "DGB7021025800",
        routeId: "DGB30000007000",
        stopName: "경북대학교북문앞",
        routeNo: "719",
        gpsLati: 35.89294,
        gpsLong: 128.61042
    )

    let router = Router<AppRoute>(root: .busstation(busStopInfo: mockBusStop))

    return RouterView(router: router)
}
