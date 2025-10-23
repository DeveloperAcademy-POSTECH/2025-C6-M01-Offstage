//
//  BusStationRowSubView.swift
//  OffStage
//
//  Created by Murphy on 10/21/25.
//
import SwiftData
import SwiftUI

struct BusStationRowSubView: View {
    @Environment(\.modelContext) private var modelContext
    let route: BusStationViewModel.RouteDetail
    let cityCode: String
    let nodeId: String
    let nodeNo: String?
    let nodeName: String

    @Query private var favorites: [Favorite]

    init(route: BusStationViewModel.RouteDetail, cityCode: String, nodeId: String, nodeNo: String?, nodeName: String) {
        self.route = route
        self.cityCode = cityCode
        self.nodeId = nodeId
        self.nodeNo = nodeNo
        self.nodeName = nodeName

        let favoriteId = "\(cityCode)-\(nodeId)-\(route.routeId)"
        _favorites = Query(filter: #Predicate { $0.id == favoriteId })
        print(
            "BusStationRowSubView init: cityCode=\(cityCode), nodeId=\(nodeId), routeId=\(route.routeId), favoriteId=\(favoriteId)"
        )
    }

    private var isSavedOn: Bool {
        !favorites.isEmpty
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label(route.routeNumber, systemImage: "bus.fill")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(route.direction)
                        .font(.subheadline)
                    Spacer()
                }
                if let routeType = route.routeType, !routeType.isEmpty {
                    Text(routeType)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if route.arrivals.isEmpty {
                    Text("도착 예정 정보가 없습니다.")
                        .foregroundColor(.secondary)
                } else {
                    HStack(spacing: 8) {
                        ForEach(route.arrivals) { arrival in
                            HStack(spacing: 8) {
                                Text(arrival.arrivalDescription)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                                if let remaining = arrival.remainingStopsDescription {
                                    Text(remaining)
                                        .foregroundColor(.secondary)
                                }
                                /** voice over 라벨링으로 활용
                                  if let vehicle = arrival.vehicleDescription {
                                      Text(vehicle)
                                          .foregroundColor(.secondary)
                                  }
                                 */
                            }
                            .font(.footnote)
                        }
                    }
                }
            }

            CircularToggleButton(isOn: isSavedOn) {
                if isSavedOn {
                    removeFavorite()
                } else {
                    addFavorite()
                }
            }
        }
    }

    private func addFavorite() {
        print("Adding favorite: cityCode=\(cityCode), nodeId=\(nodeId), routeId=\(route.routeId)")
        let favorite = Favorite(
            cityCode: cityCode,
            nodeId: nodeId,
            nodeNo: nodeNo,
            routeId: route.routeId,
            nodeName: nodeName,
            routeNo: route.routeNumber,
            direction: route.direction
        )
        modelContext.insert(favorite)
        do {
            try modelContext.save()
            print("Successfully saved favorite")
        } catch {
            print("Failed to save favorite: \(error)")
        }
    }

    private func removeFavorite() {
        print("Removing favorite: cityCode=\(cityCode), nodeId=\(nodeId), routeId=\(route.routeId)")
        if let favorite = favorites.first {
            modelContext.delete(favorite)
            do {
                try modelContext.save()
                print("Successfully removed favorite")
            } catch {
                print("Failed to remove favorite: \(error)")
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Favorite.self, configurations: .init(isStoredInMemoryOnly: true))
    return BusStationRowSubView(
        route: .sample,
        cityCode: "25",
        nodeId: "DJB8001793",
        nodeNo: "12345",
        nodeName: "포항성모병원"
    )
    .modelContainer(container)
}
