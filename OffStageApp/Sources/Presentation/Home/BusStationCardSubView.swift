import SwiftUI

struct BusStationCardSubView: View {
    let stationSempleItem: BusStationData
    @State private var isNotificationOn = false // 더미파일(실제 데이터 넣을 때는 삭제)

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(stationSempleItem.stationName)")
                    Text("\(stationSempleItem.stationNumber)")
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: {
                    isNotificationOn.toggle()
                }) {
                    Image(systemName: isNotificationOn ? "bell.circle.fill" : "bell.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            BusRouteListSubView()
        }
        .background(.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

#Preview {
    BusStationCardSubView(stationSempleItem: busStationData[0])
}
