//
//  SearchResultsView.swift
//  OffStage
//
//  Created by Murphy on 10/20/25.
//
import SwiftUI

struct SearchResultsView: View {
    let busStop: BusStopForSearch
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack {
                Divider()
                    .overlay(Color.gray.opacity(0.2))
                VStack(alignment: .leading, spacing: 8) {
                    Text(busStop.nodenm)
                        .font(.title2)
                        .fontWeight(.bold)
                    if let nodeno = busStop.nodeno, !nodeno.isEmpty {
                        Text("ID: \(nodeno)")
                            .foregroundColor(.gray)
                    }
                    if let distance = busStop.distance {
                        Text(distance)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                    }
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "bus.fill")
                            .foregroundStyle(.blue)
                        if busStop.routes.isEmpty {
                            Text("노선 정보를 불러올 수 없습니다.")
                                .foregroundColor(.secondary)
                        } else {
                            Text(busStop.routes.joined(separator: ", "))
                                .font(.callout)
                                .foregroundColor(.primary)
                        }
                        Spacer()
                    }
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview에서는 샘플 데이터를 사용
        SearchResultsView(busStop: BusStopForSearch.sampleBusStop[0]) {}
    }
}
