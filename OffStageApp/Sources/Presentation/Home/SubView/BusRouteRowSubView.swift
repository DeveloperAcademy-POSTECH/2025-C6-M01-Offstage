import BusAPI
import SwiftUI

struct BusRouteRowSubView: View {
    let routeNumber: String
    let arrivals: [BusArrival]

    var body: some View {
        VStack {
            HStack {
                // 버스 번호 표시
                Text("\(Image(systemName: "bus.fill")) \(routeNumber)")
                    .font(.title3)
                Spacer()
            }
            HStack {
                // Display up to two arrivals
                ForEach(arrivals.prefix(2).indices, id: \.self) {
                    index in
                    let arrival = arrivals[index]
                    if let estimatedArrivalTime = arrival.estimatedArrivalTime {
                        Text("\(estimatedArrivalTime / 60)분")
                            .foregroundColor(.green)
                    }
                    if let remainingStopCount = arrival.remainingStopCount {
                        Text("\(remainingStopCount)번째전")
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    // Sample BusArrival data for preview
    let sampleArrivals: [BusArrival] = [
        BusArrival(
            routeId: "GGB204000013",
            routeNumber: "111",
            routeType: "일반버스",
            nodeId: "GGB204000163",
            nodeName: "판교",
            remainingStopCount: 2,
            estimatedArrivalTime: 480,
            vehicleType: "저상"
        ),
        BusArrival(
            routeId: "GGB204000013",
            routeNumber: "111",
            routeType: "일반버스",
            nodeId: "GGB204000163",
            nodeName: "판교",
            remainingStopCount: 13,
            estimatedArrivalTime: 1320,
            vehicleType: nil
        ),
    ]
    return BusRouteRowSubView(routeNumber: "111", arrivals: sampleArrivals)
}
