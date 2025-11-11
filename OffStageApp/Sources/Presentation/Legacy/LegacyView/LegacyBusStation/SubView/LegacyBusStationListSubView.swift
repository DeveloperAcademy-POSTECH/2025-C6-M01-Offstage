import SwiftData
import SwiftUI

struct LegacyBusStationListSubView: View {
    let routes: [BusStationViewModel.RouteDetail]
    let viewInput: BusStationViewInput
    @Query private var favorites: [Favorite]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(routes) { route in
                LegacyBusStationRowSubView(
                    route: route,
                    cityCode: viewInput.cityCode,
                    nodeId: viewInput.nodeId,
                    nodeNo: viewInput.nodeNumber,
                    nodeName: viewInput.nodeName,
                    isFavorite: isFavorite(routeId: route.routeId)
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

    private func isFavorite(routeId: String) -> Bool {
        let favoriteId = "\(viewInput.cityCode)-\(viewInput.nodeId)-\(routeId)"
        return favorites.contains { $0.id == favoriteId }
    }
}
