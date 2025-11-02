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
    @StateObject private var router = Router<AppRoute>(root: .home)

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
        .modelContainer(for: Favorite.self)
    }
}
