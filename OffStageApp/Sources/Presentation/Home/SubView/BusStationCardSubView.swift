import SwiftUI

struct BusStationCardSubView: View {
    @EnvironmentObject var router: Router<AppRoute>
    // 더미파일(실제 데이터 넣을 때는 삭제)
    let stationSempleItem: BusStationData
    @State private var isNotificationOn = false

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    // 정류소 이름 표시
                    Text("\(stationSempleItem.stationName)")
                        .font(.title2)
                    // 정류소 번호 표시
                    Text("\(stationSempleItem.stationNumber)")
                        .foregroundColor(.gray)
                }
                Spacer()
                // 알림 버튼
                Button(action: {
                    // 알림 값
                    isNotificationOn.toggle()
                }) {
                    Image(systemName: isNotificationOn ? "bell.circle.fill" : "bell.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
            }
            .padding([.top, .leading, .trailing])

            if isNotificationOn == true {
                Button {
                    router.push(.busvision(routeToDetect: routes))
                } label: {
                    Text("\(Image(systemName: "camera")) 버스 인식하기")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }

            BusRouteListSubView(buses: stationSempleItem.busRoutes)
        }
        .background(.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

extension BusStationCardSubView {
    /// busvision에 전달하기 위한 계산 프로퍼티
    var routes: [String] {
        stationSempleItem.busRoutes.compactMap(\.routeNumber)
    }
}

#Preview {
    BusStationCardSubView(stationSempleItem: busStationData[0])
}
