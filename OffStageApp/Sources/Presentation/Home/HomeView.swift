import BusAPI
import SwiftData
import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var router: Router<AppRoute>
    @StateObject private var viewModel: HomeViewModel

    @StateObject private var permissionManager = PermissionManager()
    @State private var isSheetPresented = false
    @State private var busNumberInput: String = ""
    @State private var isBusStopSelectionPresented = false

    private var hasRequestedPermissions: Bool {
        UserDefaults.standard.bool(forKey: "hasRequestedPermissions")
    }

    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Text(L10n.K.appName)
                    .font(.body)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.bottom, 35)

                stopInfoView()

                HStack {
                    Text("탑승할 버스 검색")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white)
                        .padding(.top, 30)
                        .padding(.bottom, 20)

                    Spacer()
                }
                .padding(.horizontal)

                ZStack {
                    TextField(
                        "",
                        text: $busNumberInput,
                        prompt: Text(L10n.Home.Stt.askBusNumber).foregroundColor(.white.opacity(0.6))
                    )
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.leading, 25)
                    .padding(.vertical, 20)
                    .onSubmit {
                        if !busNumberInput.isEmpty {
                            router.push(.busRouteSearch(recognizedText: busNumberInput))
                            busNumberInput = ""
                        }
                    }

                    HStack {
                        Spacer()

                        micButton
                    }
                    .padding(.trailing, 10)
                }
                .background(Color(red: 0.0784, green: 0.0823, blue: 0.1059))
                .cornerRadius(99)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
        }
        .onAppear {
            if !hasRequestedPermissions {
                // 첫 실행: 권한 요청만 수행 (requestAll이 알아서 거부 체크함)
                Task {
                    await permissionManager.requestAll()
                    if permissionManager.isGranted(.location) {
                        viewModel.fetchNearestStop()
                    }
                    UserDefaults.standard.set(true, forKey: "hasRequestedPermissions")
                }
            } else {
                // 두 번째 실행 이후: 현재 권한 상태만 확인
                Task {
                    await permissionManager.checkAllPermissionsGranted()
                    if permissionManager.isGranted(.location) {
                        viewModel.fetchNearestStop()
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // 앱이 foreground로 돌아올 때 권한 재확인
            Task {
                await permissionManager.checkAllPermissionsGranted()
                if permissionManager.isGranted(.location) {
                    viewModel.fetchNearestStop()
                }
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            SheetView(
                nearestBusStop: viewModel.nearestBusStop,
                busRoutes: viewModel.busRoutes,
                onRouteSelected: { selectedRoute in
                    print("HomeView received selected route: \(selectedRoute.routeNumber)")
                    isSheetPresented = false // Dismiss the sheet
                    if let nearestStop = viewModel.nearestBusStop {
                        router.push(.busArrival(busStop: nearestStop, busRoute: selectedRoute))
                    } else {
                        print("Error: Nearest bus stop not available for navigation.")
                    }
                },
                onTextRecognized: { recognizedText in
                    print("STT 완료: \(recognizedText)")
                    isSheetPresented = false
                    if let nearestStop = viewModel.nearestBusStop {
                        router.push(.busRouteSearch(busStop: nearestStop, recognizedText: recognizedText))
                    }
                }
            )
        }
        .sheet(isPresented: $permissionManager.showPermissionDeniedSheet) {
            PermissionSubView(
                deniedPermissions: permissionManager.deniedPermissions,
                grantedPermissions: permissionManager.grantedPermissions()
            )
            .interactiveDismissDisabled(true)
        }
        .sheet(isPresented: $isBusStopSelectionPresented) { // 추가
            BusStopSelectionView(
                currentBusStop: viewModel.nearestBusStop,
                onBusStopSelected: { selectedStop in
                    viewModel.nearestBusStop = selectedStop
                    isBusStopSelectionPresented = false
                },
                onRefresh: {
                    isBusStopSelectionPresented = false // Sheet 닫기
                    viewModel.fetchNearestStop() // GPS 갱신 및 정류장 재검색
                }
            )
        }
        .onChange(of: viewModel.isLoading) { _, isLoading in
            // isLoading이 true로 바뀌는 시점에 VoiceOver로 로딩 상태를 안내한다.
            // TODO:
            // - 짧은 시간에 공지가 연속 게시되면 이전 멘트를 중단하고 새 멘트를 읽어 "문장이 씹히는" 현상이 발생함
            if isLoading {
                UIAccessibility.post(
                    notification: .announcement,
                    argument: String(localized: "home.a11y.announcement.loadingNearby")
                )
            }
        }
    }

    @ViewBuilder
    private func stopInfoView() -> some View {
        if viewModel.isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .frame(height: 60)
                .padding(.horizontal)
                .accessibilityLabel(Text(L10n.Home.A11y.Announcement.loading))
        } else if let stop = viewModel.nearestBusStop {
            ZStack {
                HStack {
                    (Text(L10n.Home.Stt.currentNearbyStopPrefix) +
                        Text(stop.name)
                        .foregroundColor(Color(.primarynormal))
                        .fontWeight(.bold) +
                        Text(L10n.Common.Ui.suffixIs)
                    )
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.white)
                    .lineSpacing(8)

                    Spacer()
                }

                HStack {
                    Spacer()

                    Button {
                        isBusStopSelectionPresented = true
                    } label: {
                        Text("변경")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color(red: 0.1098, green: 0.1176, blue: 0.1490))
                    .overlay(
                        RoundedRectangle(cornerRadius: 99)
                            .stroke(.white.opacity(0.4), lineWidth: 2)
                    )
                    .cornerRadius(99)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(Color(red: 0.0784, green: 0.0823, blue: 0.1059))
            .cornerRadius(12)
            .padding(.horizontal)

        } else {
            VStack(spacing: 10) {
                HStack {
                    Text(L10n.Home.Map.noStopsFound)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    Spacer()
                }

                Button {
                    viewModel.fetchNearestStop()
                } label: {
                    Text(L10n.Common.Ui.buttonRetry)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 15)
                        .background(Capsule().fill(Color.blue))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color(red: 0x19 / 255, green: 0x1A / 255, blue: 0x1F / 255))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }

    private var micButton: some View {
        // 활성화 조건: 주변 정류장이 있는 경우
        let isMicDisabled = viewModel.isLoading || viewModel.nearestBusStop == nil

        return Button {
            isSheetPresented = true
        } label: {
            Image(systemName: "mic")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 45, height: 45)
                .background(
                    Circle()
                        .fill(Color(red: 0.1098, green: 0.1176, blue: 0.1490))
                )
        }
        .disabled(isMicDisabled)
        .opacity(isMicDisabled ? 0.4 : 1.0)
        .accessibilityLabel(Text(L10n.Home.A11y.Button.Mic.label))
        .accessibilityHint({
            let hintKey: LocalizedStringKey = {
                if viewModel.isLoading {
                    return L10n.Home.A11y.Button.Mic.Hint.loading
                }
                if viewModel.nearestBusStop == nil {
                    return L10n.Home.A11y.Button.Mic.Hint.noStop
                }
                return L10n.Home.A11y.Button.Mic.Hint.ready
            }()
            return Text(hintKey)
        }())
    }
}
