import BusAPI
import SwiftData
import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var router: Router<AppRoute>
    @Environment(\.modelContext) private var modelContext
    @State private var locationProvider: LocationProviding = LocationManager()
    @StateObject private var permissionManager = PermissionManager()

    private var hasRequestedPermissions: Bool {
        UserDefaults.standard.bool(forKey: "hasRequestedPermissions")
    }

    var body: some View {
        VStack {
            Button {
                router.push(.quickCamera)
            } label: {
                Image("quickFindBus")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }
            .accessibilityLabel("빠른 버스 인식")
            .accessibilityHint("두번 탭해서 빠른 버스 인식 화면으로 이동할 수 있습니다.")
        }.onAppear {
            if !hasRequestedPermissions {
                Task {
                    await permissionManager.requestAll()
                    UserDefaults.standard.set(true, forKey: "hasRequestedPermissions")
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // 앱이 foreground로 돌아올 때 권한 재확인
            Task {
                await permissionManager.checkAllPermissionsGranted()
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
}
