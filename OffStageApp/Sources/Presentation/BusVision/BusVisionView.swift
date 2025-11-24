import BusAPI
import SwiftUI
import UIKit

/// router와 연결되는 메인 버스 비전 뷰
struct BusVisionView: View {
    // properties
    var busStop: BusStop
    var busRoute: BusRoute
    @StateObject var vm: BusVisionViewModel

    @EnvironmentObject var router: Router<AppRoute>
    @State var showHelpSheet: Bool = false

    // init
    init(busStop: BusStop, busRoute: BusRoute) {
        self.busStop = busStop
        self.busRoute = busRoute
        _vm = StateObject(wrappedValue: BusVisionViewModel(
            busStop: busStop,
            busRoute: busRoute
        ))
    }

    var body: some View {
        ZStack(alignment: .top) {
            // 뷰파인더 + 바운딩박스
            BusDetectionView(
                routeNumberToDetect: vm.busNumberToDetect,
                detectStatus: $vm.busDetectedState
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            TiltGuideView(offset: vm.tiltManager.offsetZ, tiltState: vm.tiltManager.tiltState)

            VStack {
                // 버스도착정보 실시간 정보
                WaitingBusRealtimeInfoView(
                    routeno: vm.busNumberToDetect,
                    arrivalSecconds: vm.alertManager.arrivalTime
                )
                .padding()

                // 버스 도착 & 지나감 알람
                if vm.alertManager.showSoonArrivalAlert {
                    SoonArrivalAlertView(routeNo: busRoute.routeNumber)
                        .offset(y: -10)
                }

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
                Text("카메라 버스 인식")
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
        .onDisappear {
            vm.tiltManager.disableHapticFeedback()
        }
    }
}
