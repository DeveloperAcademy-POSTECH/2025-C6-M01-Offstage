import BusAPI
import SwiftUI

enum AppRoute: Routable {
    case home
    case search(busStopInfo: BusStopInfo)
    case busstation(busStopInfo: BusStopInfo)
    case busvision
    case homeedit
    case onboarding
    case test(busStopInfo: BusStopInfo)

    @ViewBuilder
    func view() -> some View {
        switch self {
        case .home:
            HomeView()

        case let .search(busStopInfo):
            SearchView(busStopInfo: busStopInfo)

        case let .busstation(busStopInfo):
            BusStationView(busStopInfo: busStopInfo)

        case .busvision:
            BusVisionView()

        case .homeedit:
            HomeEditView()

        case .onboarding:
            OnboardingView()

        case let .test(busStopInfo):
            TestView(busStopInfo: busStopInfo)
        }
    }
}
