import SwiftUI

struct BusStationCardSubView: View {
    @EnvironmentObject var router: Router<AppRoute>

    let busStopData: BusStopForHome
    let isNotificationOn: Bool
    let activateNotification: () -> Void

    init(
        busStopData: BusStopForHome,
        isNotificationOn: Bool,
        activateNotification: @escaping () -> Void
    ) {
        self.busStopData = busStopData
        self.isNotificationOn = isNotificationOn
        self.activateNotification = activateNotification
    }

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    // 정류소 이름 표시
                    Text("\(busStopData.nodenm)")
                        .font(.title2)
                    // 정류소 번호 표시
                    Text("\(busStopData.nodeno)")
                        .foregroundColor(.gray)
                }
                Spacer()
                // 알림 버튼
                Button(action: activateNotification) {
                    Image(systemName: isNotificationOn ? "bell.fill" : "bell")
                        .font(.title2)
                        .foregroundColor(isNotificationOn ? .white : .gray)
                        .padding(8)
                        .background {
                            Circle()
                                .stroke(lineWidth: 2)
                                .foregroundStyle(isNotificationOn ? .blue : .gray)
                        }
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

            BusRouteListSubView(buses: busStopData.routes)
        }
        .background(.gray.opacity(0.1))
        .cornerRadius(15)
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    isNotificationOn ? .blue : .clear,
                    lineWidth: 2
                )
        }
    }
}

extension BusStationCardSubView {
    /// busvision에 전달하기 위한 계산 프로퍼티
    var routes: [String] {
        busStopData.routes.compactMap(\.routeNumber)
    }
}

#Preview {
    BusStationCardSubView(
        busStopData: busStationData[0],
        isNotificationOn: true,
        activateNotification: {}
    )
}
