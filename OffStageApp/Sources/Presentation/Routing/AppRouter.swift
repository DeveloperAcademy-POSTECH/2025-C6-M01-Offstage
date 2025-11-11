import BusAPI
import SwiftUI

enum AppRouter: Routable {
    case onboarding
    case home
    case businfo
    case busvision

    @MainActor
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .onboarding:
            OnboardingView()

        case .home:
            HomeView()

        case .businfo:
            BusInfoView()

        case .busvision:
            BusVisionView()
        }
    }
}
