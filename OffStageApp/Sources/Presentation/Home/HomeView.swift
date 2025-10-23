import BusAPI
import SwiftData
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: Router<AppRoute>
    @Environment(\.modelContext) private var modelContext
    @State private var locationProvider: LocationProviding = LocationManager()
    @State private var notificationOnStationId: String?

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
    @Query(sort: [
        SortDescriptor<Favorite>(\Favorite.nodeName),
        SortDescriptor<Favorite>(\Favorite.routeNo),
    ]) private var favorites: [Favorite]

    private var favoritedStops: [FavoritedStop] {
        let grouped = Dictionary(grouping: favorites, by: { $0.nodeId })
        return grouped.map { _, favorites in
            FavoritedStop(favorites: favorites)
        }.sorted {
            if $0.nodeName != $1.nodeName {
                $0.nodeName < $1.nodeName
            } else {
                $0.nodeId < $1.nodeId
            }
        }
    }

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

                    if !favoritedStops.isEmpty {
                        ForEach(favoritedStops) { station in
                            BusStationCardSubView(
                                stationName: station.nodeName,
                                stationNumber: station.nodeNo ?? "",
                                nodeId: station.nodeId,
                                cityCode: station.cityCode,
                                favorites: station.favorites,
                                isNotificationOn: station.id == notificationOnStationId,
                                onNotificationTap: {
                                    if notificationOnStationId == station.id {
                                        notificationOnStationId = nil
                                    } else {
                                        notificationOnStationId = station.id
                                    }
                                }
                            )
                            .padding(.horizontal)
                        }

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
                }
            }
        }
        .onAppear {
            locationProvider.requestLocationPermission()
        }
    }
}

extension HomeView {
    struct FavoritedStop: Identifiable {
        let favorites: [Favorite]
        var id: String { (favorites.first?.nodeId ?? "") + favorites.map(\.id).joined() }
        var nodeId: String { favorites.first?.nodeId ?? "" }
        var nodeName: String { favorites.first?.nodeName ?? "" }
        var nodeNo: String? { favorites.first?.nodeNo }
        var cityCode: String { favorites.first?.cityCode ?? "" }
    }
}

#Preview {
    // 미리보기용 Mock Router
    RouterView(router: Router<AppRoute>(root: .home))
}
