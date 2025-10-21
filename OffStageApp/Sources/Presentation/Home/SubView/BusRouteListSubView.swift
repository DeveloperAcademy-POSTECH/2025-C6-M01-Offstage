import SwiftUI

struct BusRouteListSubView: View {
    var body: some View {
        VStack {
            // 배열에 있는 버스 정보들를 표시
            ForEach(busSampleData) { sampleItem in
                BusRouteRowSubView(sampleItem: sampleItem)
                // 버스들 중간에 들어가는 분리 선, 표시되는 버스가 마지막 버스가 아니면 분리 선 표시!
                if sampleItem.id != busSampleData.last?.id {
                    Divider()
                }
            }
            .padding(5)
        }
        .padding()
        .background(.gray.opacity(0.2))
        .cornerRadius(15)
    }
}

#Preview {
    BusRouteListSubView()
}
