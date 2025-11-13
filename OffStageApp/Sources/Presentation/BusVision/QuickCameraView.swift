import SwiftUI

struct QuickCameraView: View {
    // properties
    /// 탐지할 노선번호
    @State var routeNumbers: [String] = []
    @State var busDetectedState: BusDetectStatus = .unDetected
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
                detectStatus: $busDetectedState
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            VStack {
                if isRouteNumEntered {
                    #if DEBUG_MODE
                        if busDetectedState == .unDetected {
                            if let first = routeNumbers.first {
                                Text(String(format: "busVision.debug.detectingWithNumber", arguments: [first]))
                            }
                        }
                    #endif
                    // 탐지 결과
                    DetectingStatusSubView(status: busDetectedState)
                        .padding(.horizontal)
                } else {
                    FastBusVisionInputView(routeNumber: $routeNumInputText) {
                        isRouteNumEntered = true
                        routeNumbers = [routeNumInputText]
                    }
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, maxHeight: 300, alignment: .center)
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
