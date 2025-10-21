//
//  SearchResultsView.swift
//  OffStage
//
//  Created by Murphy on 10/20/25.
//
// import BusAPI
import SwiftUI

struct BusStopForSearch: Identifiable {
    let id = UUID()
    /// 정류소이름
    let nodenm: String
    /// 정류소 아이디
    let nodeid: String
    /// 노선번호들
    let routes: [String]
    /// 거리(검색결과일 땐 안보이는)
    let distance: String // 타입&이름수정확률높음
}

extension BusStopForSearch {
    static let sampleBusStop = [
        BusStopForSearch(nodenm: "포항제철공고", nodeid: "299015", routes: ["111", "216"], distance: "559m"),
        BusStopForSearch(nodenm: "포항제철공고", nodeid: "299004", routes: ["111", "216"], distance: "731m"),
        BusStopForSearch(nodenm: "포항성모병원", nodeid: "300019", routes: ["111", "216"], distance: "1.3km"),
    ]
}

struct SearchResultsView: View {
    let busStop: BusStopForSearch

    var body: some View {
        VStack {
            Divider()
                .overlay(Color.gray.opacity(0.2))
            VStack(alignment: .leading, spacing: 8) {
                Text(busStop.nodenm)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(busStop.nodeid)
                Text(busStop.distance)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
                HStack {
                    Image(systemName: "bus.fill")
                    Text(busStop.routes.joined(separator: ", "))
                    Spacer()
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.2))
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview에서는 샘플 데이터를 사용
        SearchResultsView(busStop: BusStopForSearch.sampleBusStop[0])
    }
}
