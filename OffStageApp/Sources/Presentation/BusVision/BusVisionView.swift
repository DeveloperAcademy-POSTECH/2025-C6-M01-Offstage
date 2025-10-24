import SwiftUI

/// router와 연결되는 메인 버스 비전 뷰
struct BusVisionView: View {
    // properties
    var routeNumbers: [String]
    @State var detectedRouteNumbers: [String] = []

    @EnvironmentObject var router: Router<AppRoute>

    // init
    init(routeNumbers: [String]) {
        self.routeNumbers = routeNumbers
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // 뷰파인더 + 바운딩박스
            BusDetectionView(
                routeNumbersToDetect: routeNumbers,
                detectedRouteNumbers: $detectedRouteNumbers
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            // 노선번호 로딩 & 결과
            VStack {
                if detectedRouteNumbers.isEmpty {
                    ProgressView()
                } else {
                    Text(detectedRouteNumbers.joined(separator: "& "))
                        .font(.system(size: 120, weight: .black))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, maxHeight: 150, alignment: .center)
            .background {
                Rectangle()
                    .foregroundStyle(.black)
            }
        }
    }
}
