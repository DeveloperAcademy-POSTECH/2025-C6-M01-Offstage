
#if DEBUG_MODE
    import SwiftUI

    struct DebugView: View {
        @EnvironmentObject var router: Router<AppRoute>
        @Environment(\.dismiss) private var dismiss
        @StateObject private var logStore = LogStore.shared

        var body: some View {
            NavigationView {
                List {
                    ForEach(logStore.logs, id: \.self) { log in
                        Text(log)
                            .font(.system(.caption, design: .monospaced))
                            .listRowInsets(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
                    }
                    NavigationLink(
                        L10n.Debug.Ui.linkBusVision,
                        destination: BusVisionView(routeNumbers: ["207", "306"])
                    )
                    NavigationLink(
                        L10n.Debug.Ui.buttonApiTest,
                        // TODO: 새로운 L10n 키가 필요하면 추가해야 합니다.
                        destination: TestView(busStopInfo: .init(
                            cityCode: 25,
                            nodeId: "GGB204000163",
                            routeId: "GGB204000013",
                            stopName: "판교",
                            routeNo: "111",
                            gpsLati: 37.394726159,
                            gpsLong: 127.1112090472
                        ))
                    )
                }
                .navigationTitle(L10n.Debug.Ui.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(L10n.Debug.Ui.buttonClear) {
                            logStore.clearLogs()
                        }
                    }
                }
            }

            Button {
                dismiss() // 시트 닫기
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    router.push(.sttTest) // 시트 애니메이션 후 라우팅
                }
            } label: {
                Text(L10n.Debug.Ui.buttonSttTtsTest)
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
