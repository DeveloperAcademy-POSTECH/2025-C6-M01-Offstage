import SwiftUI

/// router와 연결되는 메인 버스 비전 뷰
struct BusVisionView: View {
    // properties
    var routeNumbers: [String]
    
    @EnvironmentObject var router: Router<AppRoute>

    // init
    init(routeNumbers: [String]) {
        self.routeNumbers = routeNumbers
    }

    var body: some View {
        VStack {
            BusDetectionView(routeNumbers: routeNumbers)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}
