
#if DEBUG_MODE
    import SwiftUI

    struct DebugView: View {
        @EnvironmentObject var router: Router<AppRoute>
        @Environment(\.dismiss) private var dismiss

        var body: some View {
            NavigationView {
                List {
                    NavigationLink(
                        "L10n Test View",
                        destination: L10nTestView()
                    )
                    NavigationLink(
                        L10n.Debug.Ui.linkBusVision,
                        destination: BusVisionView(routeNumbers: ["207", "306"])
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
