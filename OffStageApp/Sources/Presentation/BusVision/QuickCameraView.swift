import BusAPI
import SwiftUI

/// 빠른 버스인식 뷰
struct QuickCameraView: View {
    // properties
    @StateObject var vm: QuickCameraViewModel
    var routeNumber: String = ""

    @EnvironmentObject var router: Router<AppRoute>
    @State var showHelpSheet: Bool = false

    // init
    init(routeNo: String) {
        _vm = StateObject(wrappedValue: QuickCameraViewModel(routeNo: routeNo))
        routeNumber = routeNo
    }

    var body: some View {
        ZStack(alignment: .top) {
            // 뷰파인더 + 바운딩박스
            BusDetectionView(
                routeNumberToDetect: vm.busNumberToDetect,
                detectStatus: $vm.busDetectedState
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            VStack {
                // 버스도착정보: \(버스번호)번 버스를 인식합니다
                (
                    Text(routeNumber)
                        .foregroundColor(Color(.primarynormal))
                        .font(.title3)
                        .fontWeight(.semibold)

                        +

                        Text("번 버스를 인식합니다.")
                        .font(.title3)
                        .fontWeight(.semibold)
                )
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color.black)
                )
                .padding()

                Spacer()

                // 탐지결과
                DetectingStatusSubView(status: vm.stateToPresent)
                    .padding()
            }
            .accessibilitySortPriority(-100)
        }
        .sheet(isPresented: $showHelpSheet) {
            BusVisionHelpSheet(showSheet: $showHelpSheet)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("버스 바로 인식")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilitySortPriority(100)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showHelpSheet.toggle()
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("도움말")
                .accessibilityHint("두번 탭하여 도움말 시트를 열 수 있습니다.")
            }
        }
    }
}
