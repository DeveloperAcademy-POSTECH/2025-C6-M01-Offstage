import SwiftUI

struct BusStationListSubView: View {
    let routes: [BusStationViewModel.RouteDetail]
    let viewInput: BusStationViewInput

    var body: some View {
        VStack(spacing: 0) {
            ForEach(routes) { route in
                BusStationRowSubView(
                    route: route,
                    cityCode: viewInput.cityCode,
                    nodeId: viewInput.nodeId,
                    nodeNo: viewInput.nodeNumber,
                    nodeName: viewInput.nodeName
                )
                if route.id != routes.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
