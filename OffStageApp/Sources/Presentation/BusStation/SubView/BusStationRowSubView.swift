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
    let isFavorite: Bool

    private var isSavedOn: Bool {
        isFavorite
    }

    private var routeInfoAccessibilityLabel: String {
        var label = "\(route.routeNumber)번 버스"
        label += route.direction.isEmpty ? ", 방면 정보 없음" : ",\(route.direction) 방면"
        if route.arrivals.isEmpty {
            label += ", 도착 정보 없음"
        } else {
            for (index, arrival) in
                route.arrivals.enumerated()
            {
                var arrivalLabel = ""
                if route.arrivals.count > 1 {
                    arrivalLabel += (
                        index == 0) ? ", 첫번째 버스" : ", 두번째 버스"
                } else {
                    arrivalLabel += ","
                }

                arrivalLabel += "\(arrival.arrivalDescription)"

                if let remaining =
                    arrival.remainingStopsDescription
                {
                    arrivalLabel += ", \(remaining)"
                }
                label += arrivalLabel
            }
        }
        return label
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
                    Text(L10n.BusStation.Ui.errorNoArrivalInfo)
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
                            }
                            .font(.footnote)
                        }
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(routeInfoAccessibilityLabel)

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
        let fetchDescriptor = FetchDescriptor<Favorite>()
        let allFavorites = (try? modelContext.fetch(fetchDescriptor)) ?? []
        let stationCount = Dictionary(grouping: allFavorites, by: { $0.nodeId }).count

        let favorite = Favorite(
            cityCode: cityCode,
            nodeId: nodeId,
            nodeNo: nodeNo,
            routeId: route.routeId,
            nodeName: nodeName,
            routeNo: route.routeNumber,
            direction: route.direction,
            order: stationCount
        )
        modelContext.insert(favorite)
        try? modelContext.save()
    }

    private func removeFavorite() {
        let favoriteId = "\(cityCode)-\(nodeId)-\(route.routeId)"
        try? modelContext.delete(model: Favorite.self, where: #Predicate { $0.id == favoriteId })
        try? modelContext.save()
    }
}

#Preview {
    do {
        let container = try ModelContainer(for: Favorite.self, configurations: .init(isStoredInMemoryOnly: true))
        return BusStationRowSubView(
            route: .sample,
            cityCode: "25",
            nodeId: "DJB8001793",
            nodeNo: "12345",
            nodeName: "포항성모병원",
            isFavorite: false
        )
        .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
