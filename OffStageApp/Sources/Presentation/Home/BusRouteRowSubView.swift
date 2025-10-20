import BusAPI
import SwiftUI

struct BusRouteRowSubView: View {
    let sampleItem: BusSampleData

    var body: some View {
        VStack {
            HStack {
                Text("\(Image(systemName: "bus.fill")) \(sampleItem.routeNumber)")
                Spacer()
            }
            HStack {
                Text("\(sampleItem.endnodenm)")
                    .foregroundColor(.gray)
                Spacer()
            }
            HStack {
                Text("\(sampleItem.arrivalMinutes1 / 60)분")
                    .foregroundColor(.green)
                Text("\(sampleItem.stopsAway1)번째전")
                    .foregroundColor(.gray)
                Text("\(sampleItem.arrivalMinutes2 / 60)분")
                    .foregroundColor(.green)
                Text("\(sampleItem.stopsAway2)번째전")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
//        .background(.gray.opacity(0.2))
    }
}

#Preview {
    BusRouteRowSubView(sampleItem: busSampleData[0])
}
