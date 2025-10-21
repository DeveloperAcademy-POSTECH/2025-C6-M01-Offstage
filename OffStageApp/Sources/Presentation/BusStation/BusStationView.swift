import BusAPI
import SwiftUI

struct BusStationView: View {
    @EnvironmentObject var router: Router<AppRoute>
    var buses: [BusSampleData] = []

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    // busStopInfo.stopName
                    Text("포항성모병원")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    // busStopInfo.nodeId
                    Text("300013")
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color(.systemGray6))

            // 스크롤 영역
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 안내 문구
                    Text("자주 이용하는 버스를 등록해 주세요.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .foregroundStyle(.gray)

                    // 버스 리스트
                    if buses.isEmpty {
                        Text("노선 정보가 없습니다.")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 40)
                    } else {
                        BusStationListSubView(buses: buses)
                    }
                }
            }
        }
        .navigationBarItems(
            leading:
            Button(action: {
                router.pop()
            }, label: {
                Image(systemName: "chevron.left")
            }),
            trailing: Button(action: {
                router.popToRoot()
            }, label: {
                Image(systemName: "house")
            })
        )
    }
}

#Preview {
    BusStationView(buses: busSampleData)
}
