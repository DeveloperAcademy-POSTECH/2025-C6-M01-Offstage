import SwiftUI

struct BusRouteListSubView: View {
    var body: some View {
        VStack {
            ForEach(busSampleData) { sampleItem in
                BusRouteRowSubView(sampleItem: sampleItem)
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
