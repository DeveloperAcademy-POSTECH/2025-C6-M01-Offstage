import SwiftUI

struct RouterView<Route: Routable>: View {
    @ObservedObject var router: Router<Route>

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
