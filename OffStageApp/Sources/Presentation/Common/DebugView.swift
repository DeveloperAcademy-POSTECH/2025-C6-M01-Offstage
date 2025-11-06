#if DEBUG_MODE
    import SwiftUI

    struct DebugView: View {
        @EnvironmentObject var router: Router<AppRoute>
        @Environment(\.dismiss) private var dismiss

        private let debugSelectionKey = "Debug.MockLocationType"
        @State private var isForceSuyu: Bool = {
            let raw = UserDefaults.standard.string(forKey: "Debug.MockLocationType")
            return raw == "suyu"
        }()

        @State private var isForceDaegu: Bool = {
            let raw = UserDefaults.standard.string(forKey: "Debug.MockLocationType")
            return raw == "daegu"
        }()

        private func updateSelection(_ type: String?) {
            if let t = type {
                UserDefaults.standard.set(t, forKey: debugSelectionKey)
            } else {
                UserDefaults.standard.set("none", forKey: debugSelectionKey)
            }
        }

        var body: some View {
            NavigationView {
                List {
                    Section(header: Text("Location")) {
                        Toggle("Force 수유역 위치 (Debug)", isOn: $isForceSuyu)
                            .onChange(of: isForceSuyu) { newValue in
                                #if DEBUG
                                    if newValue {
                                        // enable suyu and disable others
                                        LocationManager.shared.setMockLocationEnabled(
                                            true,
                                            coordinate: .init(latitude: 37.6371095, longitude: 127.0247325)
                                        )
                                        isForceDaegu = false
                                        updateSelection("suyu")
                                    } else {
                                        LocationManager.shared.setMockLocationEnabled(false)
                                        updateSelection(nil)
                                    }
                                #endif
                            }

                        Toggle("Force 대구대학교 위치 (Debug)", isOn: $isForceDaegu)
                            .onChange(of: isForceDaegu) { newValue in
                                #if DEBUG
                                    if newValue {
                                        // enable Daegu University and disable others
                                        LocationManager.shared.setMockLocationEnabled(
                                            true,
                                            coordinate: .init(latitude: 35.8990476, longitude: 128.8437207)
                                        )
                                        isForceSuyu = false
                                        updateSelection("daegu")
                                    } else {
                                        LocationManager.shared.setMockLocationEnabled(false)
                                        updateSelection(nil)
                                    }
                                #endif
                            }
                    }
                    NavigationLink(
                        L10n.Debug.Ui.linkBusVision,
                        destination: BusVisionView(routeNumbers: ["207", "306"])
                    )
                    NavigationLink(
                        L10n.Debug.Ui.buttonApiTest,
                        // TODO: 새로운 L10n 키가 필요하면 추가해야 합니다.
                        destination: TestView(busStopInfo: .init(
                            cityCode: 31020,
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
