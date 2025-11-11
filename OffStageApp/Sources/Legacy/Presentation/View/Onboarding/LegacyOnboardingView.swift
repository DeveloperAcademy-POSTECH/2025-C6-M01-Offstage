import SwiftUI

struct OnboardingPage {
    let title: Text
    let imageName: String
    let ctaTitle: LocalizedStringKey // 페이지별 버튼 라벨을 명시
}

struct LegacyOnboardingView: View {
    @EnvironmentObject var router: LegacyRouter<AppRoute>
    @State private var currentPage = 0
    @State private var didFinishOnboarding = false
    private let startPage = OnboardingPage(
        title: Text(L10n.K.appName)
            .foregroundColor(Color(red: 229 / 255, green: 255 / 255, blue: 0 / 255)) +
            Text(L10n.Onboarding.Ui.titleStart),
        imageName: "BusImage",
        ctaTitle: L10n.Onboarding.Ui.buttonStartCTA
    )

    private let pages: [OnboardingPage] = [
        .init(
            title: Text(L10n.Onboarding.Ui.titlePage1),
            imageName: "BusStation",
            ctaTitle: L10n.Common.Ui.buttonNext
        ),
        .init(
            title: Text(L10n.Onboarding.Ui.titlePage2),
            imageName: "BusVision",
            ctaTitle: L10n.Common.Ui.buttonNext
        ),
        .init(
            title: Text(L10n.Onboarding.Ui.titlePage3),
            imageName: "BusHome",
            ctaTitle: L10n.Common.Ui.buttonNext
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Group {
                if currentPage == 0 {
                    // 시작 화면
                    OnboardingStartView(
                        page: startPage,
                        pageIndex: 0,
                        nextButtonTapped: { currentPage += 1 }
                    )
                } else if currentPage >= 1, currentPage <= pages.count {
                    // 중간 페이지들 (재사용)
                    OnboardingPageView(
                        page: pages[currentPage - 1],
                        pageIndex: currentPage - 1,
                        previousButtonTapped: {
                            if currentPage > 0 {
                                currentPage -= 1
                            }
                        },
                        nextButtonTapped: { currentPage += 1 }
                    )
                } else if currentPage == pages.count + 1 {
                    // 권한 화면
                    OnboardingPermissionsView(
                        previousButtonTapped: {
                            if currentPage > 0 {
                                currentPage -= 1
                            }
                        },
                        onFinish: {
                            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                            router.root = .home
                        }
                    )
                }
            }
        }
        .animation(.easeInOut, value: currentPage)
    }
}

#Preview {
    LegacyRouterView(router: LegacyRouter<AppRoute>(root: .onboarding))
}
