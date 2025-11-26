import SwiftData
import SwiftUI

#if DEBUG_MODE
    struct DebugOverlay<Content: View>: View {
        @ObservedObject var router: Router<AppRoute>
        @ViewBuilder let content: Content
        @State private var showDebugSheet = false
        @State private var position: CGPoint = .init(
            x: UIScreen.main.bounds.width - 44,
            y: UIScreen.main.bounds.height - 100
        )
        @State private var isButtonVisible = true
        @State private var tapCount = 0
        @State private var tapTimer: Timer?

        var body: some View {
            ZStack(alignment: .bottomLeading) {
                content

                if isButtonVisible {
                    Button(action: {
                        showDebugSheet.toggle()
                    }) {
                        Image(systemName: "ant.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .foregroundColor(.red)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .position(position)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                position = value.location
                            }
                    )
                    .sheet(isPresented: $showDebugSheet) {
                        DebugView()
                            .environmentObject(router)
                    }
                }

                // 좌하단 숨김 영역 (100x100)
                Color.clear
                    .frame(width: 100, height: 100)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        handleSecretTap()
                    }
            }
        }

        private func handleSecretTap() {
            tapCount += 1

            tapTimer?.invalidate()
            tapTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                tapCount = 0
            }

            if tapCount >= 5 {
                isButtonVisible.toggle()
                tapCount = 0
                tapTimer?.invalidate()
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
