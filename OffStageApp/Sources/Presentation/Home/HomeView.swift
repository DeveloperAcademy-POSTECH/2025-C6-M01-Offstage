import BusAPI
import SwiftData
import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var router: Router<AppRoute>
    @StateObject private var viewModel: HomeViewModel

    @StateObject private var permissionManager = PermissionManager()
    @State private var isSheetPresented = false

    private var hasRequestedPermissions: Bool {
        UserDefaults.standard.bool(forKey: "hasRequestedPermissions")
    }

    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                stopInfoView()

                Text(L10n.Home.Stt.askBusNumber)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.vertical, 90)

                micButton

                Spacer()
            }
            .padding(.top)
        }
        .onAppear {
            Task {
                await permissionManager.checkAllPermissionsGranted()
                if permissionManager.isGranted(.location) {
                    viewModel.fetchNearestStop()
                }
            }

            if !hasRequestedPermissions {
                Task {
                    await permissionManager.requestAll()
                    if permissionManager.isGranted(.location) {
                        viewModel.fetchNearestStop()
                    }
                    UserDefaults.standard.set(true, forKey: "hasRequestedPermissions")
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
            .padding()
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(Color(red: 0x19 / 255, green: 0x1A / 255, blue: 0x1F / 255))
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
                .font(.system(size: 45, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 90, height: 90)
                .background(
                    Circle()
                        .fill(Color.black)
                )
                .overlay(
                    Circle()
                        .stroke(Color(.primarynormal), lineWidth: 6)
                        .scaleEffect(1.2)
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
