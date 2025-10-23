import SwiftData
import SwiftUI

@main
struct OffStageApp: App {
    @StateObject private var router = Router<AppRoute>(root: .home)

    var body: some Scene {
        WindowGroup {
            RouterView(router: router)
        }
        .modelContainer(for: Favorite.self)
    }
}
