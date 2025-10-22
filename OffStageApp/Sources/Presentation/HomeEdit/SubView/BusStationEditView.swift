import SwiftUI

struct BusStationEditView: View {
    let stationItem: BusStationData

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stationItem.stationName)
                    .font(.title2)
                HStack {
                    Text(stationItem.stationNumber)
                        .foregroundColor(.gray)
                    Text("(시청방면)")
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Button {} label: { Image(systemName: "line.3.horizontal") }

            Button {} label: { Image(systemName: "trash") }
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 30)
        .background(.gray.opacity(0.4))
        .cornerRadius(15)
    }
}

#Preview {
    BusStationEditView(stationItem: busStationData[0])
}
