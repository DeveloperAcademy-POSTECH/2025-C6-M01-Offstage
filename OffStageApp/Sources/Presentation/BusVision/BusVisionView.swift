import SwiftUI
import UIKit

/// router와 연결되는 메인 버스 비전 뷰
struct BusVisionView: View {
    // properties
    var routeNumbers: [String]
    @StateObject var vm: BusVisionViewModel = .init()

    @EnvironmentObject var router: Router<AppRoute>

    // init
    init(routeNumbers: [String]) {
        self.routeNumbers = routeNumbers
    }

    var body: some View {
        ZStack(alignment: .top) {
            // 뷰파인더 + 바운딩박스
            BusDetectionView(
                routeNumbersToDetect: routeNumbers.map { $0.removeParenthesesContent() },
                detectStatus: $vm.busDetectedState
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            // 탐지결과
            DetectingStatusSubView(status: vm.stateToPresent)
                .padding(.horizontal)
        }
    }
}
