import SwiftUI

enum AppRoute: Routable {
    case home
    case search
    case busstation
    case busvision
    case homeedit
    case onboarding

    @ViewBuilder
    func view() -> some View {
        switch self {
        case .home:
            HomeView()

        case .search:
            SearchView()

        case .busstation:
            BusStationView()

        case .busvision:
            BusVisionView()

        case .homeedit:
            HomeEditView()

        case .onboarding:
            OnboardingView()
        }
    }
}
