import SwiftUI

struct QuickCameraView: View {
    // properties
    /// 탐지할 노선번호
    @State var routeNumbers: [String] = []
    /// 실시간 탐지된 노선번호
    @State var detectedRouteNumbers: [String] = []

    /// 비전 타입
    @State var isRouteNumEntered: Bool = false
    /// 빠른 버스탐지일 때 입력받을 노선번호텍스트용
    @State var routeNumInputText: String = ""

    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
        ZStack(alignment: .bottom) {
            // 뷰파인더 + 바운딩박스
            BusDetectionView(
                routeNumbersToDetect: routeNumbers.map { $0.removeParenthesesContent() },
                detectedRouteNumbers: $detectedRouteNumbers
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            VStack {
                if isRouteNumEntered {
                    #if DEBUG_MODE
                        if detectedRouteNumbers.isEmpty {
                            Text("\(routeNumbers.first!)번 탐지중")
                        }
                    #endif
                    // 노선번호 로딩 & 결과
                    AccurateBusVisionOutputView(detectedRouteNumbers: detectedRouteNumbers)
                } else {
                    FastBusVisionInputView(routeNumber: $routeNumInputText) {
                        isRouteNumEntered = true
                        routeNumbers = [routeNumInputText]
                    }
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

#Preview {
    QuickCameraView()
}
