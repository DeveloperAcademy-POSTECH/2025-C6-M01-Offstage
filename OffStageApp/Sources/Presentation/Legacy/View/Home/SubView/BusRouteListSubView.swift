import BusAPI // Import BusAPI for BusArrival
import SwiftUI

struct BusRouteListSubView: View {
    let busArrivals: [BusArrival]

    var body: some View {
        VStack {
            // Group arrivals by route number
            ForEach(busArrivals.groupedByRouteNumber().keys.sorted(), id: \.self) {
                routeNumber in
                if let arrivalsForRoute = busArrivals.groupedByRouteNumber()[routeNumber] {
                    BusRouteRowSubView(
                        routeNumber: routeNumber,
                        arrivals: arrivalsForRoute
                    )
                    // Add a Divider if it's not the last route
                    if routeNumber != busArrivals.groupedByRouteNumber().keys.sorted().last {
                        Divider()
                    }
                }
            }
            .padding(5)
        }
        .padding()
        .background(.gray.opacity(0.2))
        .cornerRadius(15)
    }
}

// Helper extension to group BusArrivals by routeNumber
extension [BusArrival] {
    func groupedByRouteNumber() -> [String: [BusArrival]] {
        Dictionary(grouping: self, by: \.routeNumber)
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
        BusArrival(
            routeId: "GGB204000065",
            routeNumber: "9607",
            routeType: "직행좌석버스",
            nodeId: "GGB204000163",
            nodeName: "판교",
            remainingStopCount: 1,
            estimatedArrivalTime: 300,
            vehicleType: nil
        ),
    ]
    return BusRouteListSubView(busArrivals: sampleArrivals)
}
