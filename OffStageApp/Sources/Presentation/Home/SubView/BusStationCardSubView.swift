import BusAPI
import SwiftUI

struct BusStationCardSubView: View {
    @EnvironmentObject var router: Router<AppRoute>
    @StateObject private var viewModel: BusStationCardViewModel

    let stationName: String
    let stationNumber: String
    let nodeId: String
    let cityCode: String

    // 더미파일(실제 데이터 넣을 때는 삭제)
    @State private var isNotificationOn = false

    init(
        stationName: String,
        stationNumber: String,
        nodeId: String,
        cityCode: String,
        busRepository: BusRepository = DefaultBusRepository()
    ) {
        self.stationName = stationName
        self.stationNumber = stationNumber
        self.nodeId = nodeId
        self.cityCode = cityCode
        _viewModel = StateObject(wrappedValue: BusStationCardViewModel(
            busRepository: busRepository,
            nodeId: nodeId,
            cityCode: cityCode
        ))
    }

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    // 정류소 이름 표시
                    Text("\(stationName)")
                        .font(.title2)
                    // 정류소 번호 표시
                    Text("\(stationNumber)")
                        .foregroundColor(.gray)
                }
                Spacer()
                // 알림 버튼
                //                Button(action: activateNotification) {
                //                    Image(systemName: isNotificationOn ? "bell.fill" : "bell")
                //                        .font(.title2)
                //                        .foregroundColor(isNotificationOn ? .white : .gray)
                //                        .padding(8)
                //                        .background {
                //                            Circle()
                //                                .stroke(lineWidth: 2)
                //                                .foregroundStyle(isNotificationOn ? .blue : .gray)
                //                        }
                //                }
            }
            .padding([.top, .leading, .trailing])

            if isNotificationOn == true {
                Button {
                    router.push(.busvision(routeToDetect: [""]))
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

            BusRouteListSubView(busArrivals: viewModel.busArrivals)
        }
        .background(.gray.opacity(0.1))
        .cornerRadius(15)
        .task {
            await viewModel.fetchArrivals()
        }
    }
}

#Preview {
    BusStationCardSubView(stationName: "포항공과대학교", stationNumber: "12341234", nodeId: "GGB204000163", cityCode: "31020")
        .environmentObject(Router<AppRoute>(root: .home))
}
