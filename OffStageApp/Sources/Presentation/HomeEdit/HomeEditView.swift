import SwiftUI

struct HomeEditView: View {
    @EnvironmentObject var router: Router<AppRoute>
    let stations: [BusStationData]

    var body: some View {
        VStack {
            ScrollView {
                ForEach(stations) { station in
                    BusStationEditView(stationItem: station)
                }
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("홈 화면 편집")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    HomeEditView(stations: busStationData)
}
