import BusAPI
import SwiftData
import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var router: Router<AppRoute>
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var permissionManager = PermissionManager()

    private var hasRequestedPermissions: Bool {
        UserDefaults.standard.bool(forKey: "hasRequestedPermissions")
    }

    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(L10n.K.appName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Button {
                    // TODO: Navigate to settings
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)

            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(height: 60)
                    .padding(.horizontal)
            } else if let stop = viewModel.nearestBusStop {
                HStack {
                    let text = "현재 주변 정류장은\n**\(stop.name)** 입니다."
                    let attributedString = (try? AttributedString(markdown: text)) ?? AttributedString()
                    Text(attributedString)
                        .font(.system(size: 20, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(Color.black.opacity(0.5))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                Text("주변 정류장을 찾을 수 없습니다.\n위치 서비스를 확인해주세요.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .frame(height: 60)
                    .padding(.horizontal)
            }

            Spacer()

            Text("몇 번 버스를\n탑승하시나요?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)

            Spacer()

            micButton
                .padding(.bottom, 60)
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
        .sheet(isPresented: $permissionManager.showPermissionDeniedSheet) {
            PermissionSubView(
                deniedPermissions: permissionManager.deniedPermissions,
                grantedPermissions: permissionManager.grantedPermissions()
            )
            .interactiveDismissDisabled(true)
        }
    }

    private var micButton: some View {
        Button {
            // TODO: Start voice recognition
        } label: {
            Image(systemName: "mic.fill")
                .font(.system(size: 40))
                .foregroundColor(.black)
                .frame(width: 100, height: 100)
                .background(
                    Circle()
                        .fill(Color.yellow)
                )
                .overlay(
                    Circle()
                        .stroke(Color.yellow, lineWidth: 4)
                        .scaleEffect(1.2)
                )
        }
    }
}
