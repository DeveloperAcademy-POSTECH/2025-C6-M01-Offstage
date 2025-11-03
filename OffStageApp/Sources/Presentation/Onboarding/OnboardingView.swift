import SwiftUI

struct OnboardingPage {
    let title: String
    let imageName: String
    let ctaTitle: String // 페이지별 버튼 라벨을 명시
}

struct OnboardingView: View {
    @EnvironmentObject var router: Router<AppRoute>
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        .init(
            title: "당신의 하루를 더 편하게",
            imageName: "BusImage",
            ctaTitle: "시작하기"
        ), // 1페이지도 '시작하기'로 하고 싶다면 이렇게
        .init(
            title: "한눈에 관리되는 스마트 시스템",
            imageName: "BusCard1",
            ctaTitle: "다음"
        ),
        .init(
            title: "데이터가 나를 이해할 때",
            imageName: "",
            ctaTitle: "다음"
        ),
        .init(
            title: "지금 시작해보세요",
            imageName: "BusCard2",
            ctaTitle: "다음"
        ), // 마지막도 '시작하기'
    ]

    var body: some View {
        VStack(spacing: 0) {
            OnboardingPageView(
                page: pages[currentPage],
                nextButtonTapped: {
                    if currentPage == pages.count - 1 {
                        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                        router.root = .home
                    } else {
                        currentPage += 1
                    }
                }
            )
        }
        .animation(.easeInOut, value: currentPage)
    }
}

#Preview {
    RouterView(router: Router<AppRoute>(root: .onboarding))
}
