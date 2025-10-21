//
//  BusStationListSubView.swift
//  OffStage
//
//  Created by Murphy on 10/21/25.
//
import SwiftUI

struct BusStationListSubView: View {
    let buses: [BusSampleData]

    var body: some View {
        VStack {
            ForEach(buses) { sampleItem in
                BusStationRowSubView(sampleItem: sampleItem)
                // 버스들 중간에 들어가는 분리 선, 표시되는 버스가 마지막 버스가 아니면 분리 선 표시!
                if sampleItem.id != buses.last?.id {
                    Divider()
                }
            }
            .padding(5)
        }
        .padding()
        .background(.gray.opacity(0.2))
    }
}

#Preview {
    BusStationListSubView(buses: busSampleData)
}
