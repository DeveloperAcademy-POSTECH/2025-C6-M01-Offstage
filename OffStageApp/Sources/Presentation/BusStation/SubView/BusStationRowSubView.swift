//
//  BusStationRowSubView.swift
//  OffStage
//
//  Created by Murphy on 10/21/25.
//
import SwiftUI

struct BusStationRowSubView: View {
    let route: BusStationViewModel.RouteDetail
    @State private var isSavedOn = false

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label(route.routeNumber, systemImage: "bus.fill")
                        .font(.title3)
                        .fontWeight(.semibold)
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

            CircularToggleButton(isOn: $isSavedOn)
        }
    }
}

#Preview {
    BusStationRowSubView(route: .sample)
}
