
#if DEBUG_MODE
    import BusAPI
    import CoreLocation
    import SwiftUI

    struct DebugView: View {
        @EnvironmentObject var router: Router<AppRoute>
        @Environment(\.dismiss) private var dismiss
        private let locationManager = LocationManager.shared

        // 위치 오버라이드 상태
        @State private var isLocationOverrideEnabled: Bool = false
        @State private var overrideLatitude: String = "37.3918667"
        @State private var overrideLongitude: String = "127.1118833"

        // Mock 데이터 사용 여부
        @State private var useMockData: Bool = AppSettings.useMockData

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
                    Section(header: Text("API 설정")) {
                        Toggle("Mock 데이터 사용", isOn: $useMockData)
                            .onChange(of: useMockData) { _, newValue in
                                AppSettings.useMockData = newValue
                            }

                        if useMockData {
                            Text("✅ Mock 데이터 모드: 네트워크 없이 시연 가능")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text("📡 실제 API 모드: 실시간 버스 정보 조회")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }

                    Section(header: Text("위치 오버라이드")) {
                        Toggle("위치 강제 설정", isOn: $isLocationOverrideEnabled)
                            .onChange(of: isLocationOverrideEnabled) { _, newValue in
                                locationManager.isOverrideEnabled = newValue
                                if newValue {
                                    applyLocationOverride()
                                }
                            }

                        if isLocationOverrideEnabled {
                            HStack {
                                Text("위도:")
                                    .frame(width: 60, alignment: .leading)
                                TextField("Latitude", text: $overrideLatitude)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                            }

                            HStack {
                                Text("경도:")
                                    .frame(width: 60, alignment: .leading)
                                TextField("Longitude", text: $overrideLongitude)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                            }

                            Button("위치 적용") {
                                applyLocationOverride()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("프리셋 위치")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Button("판교역동편 (37.3918667, 127.1118833)") {
                                    overrideLatitude = "37.3918667"
                                    overrideLongitude = "127.1118833"
                                    applyLocationOverride()
                                }

                                Button("대구대 (35.8969259, 128.8492439)") {
                                    overrideLatitude = "35.8969259"
                                    overrideLongitude = "128.8492439"
                                    applyLocationOverride()
                                }

                                Button("수유역 (37.6368722, 127.0246917)") {
                                    overrideLatitude = "37.6368722"
                                    overrideLongitude = "127.0246917"
                                    applyLocationOverride()
                                }
                            }
                        }
                    }

                    Section(header: Text("테스트 화면")) {
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
                        NavigationLink(
                            "기울기테스트",
                            destination: TiltDebugView()
                        )
                    }
                }
                .navigationTitle(L10n.Debug.Ui.title)
                .navigationBarTitleDisplayMode(.inline)
            }

            Spacer()
        }

        private func applyLocationOverride() {
            guard let lat = Double(overrideLatitude),
                  let lon = Double(overrideLongitude),
                  lat >= -90, lat <= 90,
                  lon >= -180, lon <= 180
            else {
                print("⚠️ 유효하지 않은 좌표: lat=\(overrideLatitude), lon=\(overrideLongitude)")
                return
            }

            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            locationManager.overrideLocation = coordinate
            print("✅ 위치 오버라이드 적용: \(lat), \(lon)")
        }
    }

    struct DebugView_Previews: PreviewProvider {
        static var previews: some View {
            DebugView()
                .environmentObject(Router<AppRoute>(root: .home))
        }
    }
#endif
