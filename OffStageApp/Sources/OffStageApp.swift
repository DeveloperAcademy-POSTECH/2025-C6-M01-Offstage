import SwiftData
import SwiftUI

#if DEBUG_MODE
    struct DebugOverlay<Content: View>: View {
        @ObservedObject var router: NewRouter<NewAppRoute>
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
    @StateObject private var router: NewRouter<NewAppRoute>

    init() {
        #if DEBUG_MODE
            _router = StateObject(wrappedValue: NewRouter(root: .onboardingnew))
        #else
            let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
            _router = StateObject(wrappedValue: NewRouter(root: hasLaunchedBefore ? .homenew : .onboardingnew))
        #endif
    }

    var body: some Scene {
        WindowGroup {
            #if DEBUG_MODE
                DebugOverlay(router: router) {
                    NewRouterView(router: router)
                }
            #else
                NewRouterView(router: router)
            #endif
        }
        .modelContainer(for: Favorite.self)
    }
}
