
#if DEBUG_MODE
    import BusAPI
    import SwiftUI

    struct DebugView: View {
        @EnvironmentObject var router: Router<AppRoute>
        @Environment(\.dismiss) private var dismiss

        // 테스트용 버스 정류장 및 노선 정보
        private let testBusStop = BusStop(
            nodeId: "GGB206000635",
            name: "판교역동편",
            number: "7489",
            cityCode: 31020,
            latitude: 37.3918667,
            longitude: 127.1118833
        )

        private let testBusRoute = BusRoute(
            routeId: "GGB228000179",
            routeNumber: "101"
        )

        var body: some View {
            NavigationView {
                List {
                    NavigationLink(
                        "L10n Test View",
                        destination: L10nTestView()
                    )
                    NavigationLink(
                        L10n.Debug.Ui.linkBusVision,
                        destination: BusVisionView(
                            busStop: testBusStop,
                            busRoute: testBusRoute
                        )
                    )
                    NavigationLink(
                        "빠른버스",
                        destination: QuickCameraView()
                    )
                    NavigationLink(
                        L10n.Debug.Ui.buttonApiTest,
                        destination: TestView()
                    )
                    NavigationLink(
                        "MVP API Flow Test",
                        destination: MVPTestView()
                    )
                    NavigationLink(
                        L10n.Debug.Ui.buttonSttTtsTest,
                        destination: STTandTTSTestView()
                    )
                }
                .navigationTitle(L10n.Debug.Ui.title)
                .navigationBarTitleDisplayMode(.inline)
            }

            Spacer()
        }
    }

    struct DebugView_Previews: PreviewProvider {
        static var previews: some View {
            DebugView()
                .environmentObject(Router<AppRoute>(root: .home))
        }
    }
#endif
