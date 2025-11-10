import SwiftUI

struct NewRouterView<Route: NewRoutable>: View {
    @ObservedObject var router: NewRouter<Route>

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
