import SwiftUI

struct LegacyRouterView<Route: LegacyRoutable>: View {
    @ObservedObject var router: LegacyRouter<Route>

    var body: some View {
        NavigationStack(path: $router.paths) {
            router.root.view()
                .navigationDestination(for: Route.self) { route in
                    route.view()
                }
        }
        .environmentObject(router)
    }
}
