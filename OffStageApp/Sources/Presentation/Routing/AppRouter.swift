import BusAPI
import SwiftUI

enum AppRouter: Routable {
    case onboardingnew
    case homenew
    case businfonew
    case busvisionnew

    @MainActor
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .onboardingnew:
            OnboardingNewView()

        case .homenew:
            HomeNewView()

        case .businfonew:
            BusInfoNewView()

        case .busvisionnew:
            BusVisionNewView()
        }
    }
}
