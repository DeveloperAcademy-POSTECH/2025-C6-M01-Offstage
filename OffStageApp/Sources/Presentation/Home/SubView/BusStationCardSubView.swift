import BusAPI
import SwiftUI

struct BusStationCardSubView: View {
    @EnvironmentObject var router: Router<AppRoute>
    @StateObject private var viewModel: BusStationCardViewModel

    let stationName: String
    let stationNumber: String
    let nodeId: String
    let cityCode: String
    let favorites: [Favorite]
    let refreshTrigger: UUID

    init(
        stationName: String,
        stationNumber: String,
        nodeId: String,
        cityCode: String,
        favorites: [Favorite],
        refreshTrigger: UUID,
        busRepository: BusRepository = MainBusRepository()
    ) {
        self.stationName = stationName
        self.stationNumber = stationNumber
        self.nodeId = nodeId
        self.cityCode = cityCode
        self.favorites = favorites
        self.refreshTrigger = refreshTrigger
        _viewModel = StateObject(wrappedValue: BusStationCardViewModel(
            busRepository: busRepository,
            nodeId: nodeId,
            cityCode: cityCode,
            favorites: favorites
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
            }
            .padding([.top, .leading, .trailing])

            BusRouteListSubView(busArrivals: viewModel.busArrivals)

            Button {
                let destination = AppRoute.busVision(routeToDetect: favorites.map(\.routeNo))
                router.push(destination)
            } label: {
                Text("\(Image(systemName: "camera")) 버스 인식하기")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.primarynormal))
                    .cornerRadius(10)
            }
            .padding()
        }
        .background(.gray.opacity(0.1))
        .cornerRadius(15)
        .task {
            await viewModel.fetchArrivals()
        }
        .onChange(of: refreshTrigger) {
            Task {
                await viewModel.fetchArrivals()
            }
        }
    }
}

#Preview {
    BusStationCardSubView(
        stationName: "포항공과대학교",
        stationNumber: "12341234",
        nodeId: "GGB204000163",
        cityCode: "31020",
        favorites: [],
        refreshTrigger: UUID()
    )
    .environmentObject(Router<AppRoute>(root: .home))
}
