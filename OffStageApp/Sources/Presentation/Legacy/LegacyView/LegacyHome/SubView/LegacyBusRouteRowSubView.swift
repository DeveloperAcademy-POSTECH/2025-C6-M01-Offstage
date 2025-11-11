import BusAPI
import SwiftUI

struct LegacyBusRouteRowSubView: View {
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
                ForEach(arrivals.prefix(2).indices, id: \.self) { index in
                    let arrival = arrivals[index]
                    VStack(alignment: .leading) {
                        if let estimatedArrivalTime = arrival.estimatedArrivalTime {
                            let description = estimatedArrivalTime < 60 ? "곧 도착" : "\(estimatedArrivalTime / 60)분"
                            Text(description)
                                .foregroundColor(.green)
                        } else {
                            Text("정보 없음")
                                .foregroundColor(.secondary)
                        }
                        if let remainingStopCount = arrival.remainingStopCount {
                            Text("\(remainingStopCount)번째전")
                                .foregroundColor(.gray)
                        }
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
    return LegacyBusRouteRowSubView(routeNumber: "111", arrivals: sampleArrivals)
}
