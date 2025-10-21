import BusAPI
import SwiftUI

struct SearchView: View {
    @EnvironmentObject var router: Router<AppRoute>
    let busStopInfo: BusStopInfo
    let busStops = BusStopForSearch.sampleBusStop
    @State private var name = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack (alignment: .leading) {
                    VStack {
                        Text("주변 정류장")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)

                    VStack(spacing: 0) {

                        ForEach(busStops) { busStop in
                            Button(action: {
                                router.push(.busstation(busStopInfo: busStopInfo))
                            }) {
                                SearchResultsView(busStop: busStop)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        Divider()
                            .overlay(Color.gray.opacity(0.2))
                    }
                    
                }
                .padding(.horizontal, 16)
                .navigationBarItems(leading:
                    Button(action: {
                        router.popToRoot()
                    }, label: {
                        Image(systemName: "chevron.left")
                    })
                )
                .toolbar {
                    ToolbarItem(placement: .principal) { // 툴바 항목 배치
                        TextField("검색...", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle()) // 텍스트 필드 스타일
                            .padding(.vertical, 4) // 좌우 여백 추가
                    }
                }
                
            }
        }
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
