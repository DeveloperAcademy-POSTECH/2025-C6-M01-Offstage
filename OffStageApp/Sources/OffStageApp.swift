import SwiftData
import SwiftUI

#if DEBUG_MODE
    struct DebugOverlay<Content: View>: View {
        @ObservedObject var router: Router<AppRoute>
        @ViewBuilder let content: Content
        @State private var showDebugSheet = false

        var body: some View {
            ZStack(alignment: .bottomTrailing) {
                content

                Button(action: {
                    showDebugSheet.toggle()
                }) {
                    Image(systemName: "ant.circle.fill")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .foregroundColor(.red)
                        .background(Color.white)
                        .clipShape(Circle())
                        .padding()
                }
                .sheet(isPresented: $showDebugSheet) {
                    DebugView()
                        .environmentObject(router)
                }
            }
        }
    }
#endif

@main
struct OffStageApp: App {
    @StateObject private var router: Router<AppRoute>
    @StateObject private var backgroundLocationManager = BackgroundLocationManager()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        #if DEBUG_MODE
            _router = StateObject(wrappedValue: Router(root: .permissionGuide))
        #else
            let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
            // TODO: 온보딩 뷰 제작 후 .onboarding 으로 변경
            _router = StateObject(wrappedValue: Router(root: hasLaunchedBefore ? .home : .permissionGuide))
        #endif
    }

    var body: some Scene {
        WindowGroup {
            #if DEBUG_MODE
                DebugOverlay(router: router) {
                    RouterView(router: router)
                }
            #else
                RouterView(router: router)
            #endif
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                backgroundLocationManager.startBackgroundTracking()
            case .active:
                backgroundLocationManager.stopBackgroundTracking()
            case .inactive:
                break
            @unknown default:
                break
            }
        }
    }
}
