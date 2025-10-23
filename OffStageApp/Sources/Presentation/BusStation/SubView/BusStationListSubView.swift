//
//  BusStationListSubView.swift
//  OffStage
//
//  Created by Murphy on 10/21/25.
//
import SwiftUI

struct BusStationListSubView: View {
    let routes: [BusStationViewModel.RouteDetail]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(routes) { route in
                BusStationRowSubView(route: route)
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
