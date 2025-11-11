import BusAPI
import SwiftData
import SwiftUI
import UIKit

// TODO: 정류장 데이터 없을 시, mic 버튼 비활성화
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
                ZStack {
                    Text(L10n.K.appName)
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    HStack {
                        Spacer()
                        Button {
                            // TODO: Navigate to settings
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)

                stopInfoView()

                Text("몇 번 버스를\n탑승하시나요?")
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
    }

    @ViewBuilder
    private func stopInfoView() -> some View {
        if viewModel.isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .frame(height: 60)
                .padding(.horizontal)
        } else if let stop = viewModel.nearestBusStop {
            HStack {
                (Text("현재 주변 정류장은\n") +
                    Text(stop.name)
                    .foregroundColor(Color(.primarynormal))
                    .fontWeight(.bold) +
                    Text(" 입니다.")
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
                    Text("주변 탐색된 정류장이\n없습니다.")
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    Spacer()
                }

                Button {
                    viewModel.fetchNearestStop()
                } label: {
                    Text("재시도")
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
        Button {
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
    }
}
