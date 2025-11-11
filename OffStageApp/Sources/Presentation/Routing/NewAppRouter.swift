import BusAPI
import SwiftUI

enum NewAppRoute: NewRoutable {
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
