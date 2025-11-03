import SwiftUI

struct OnboardingPage {
    let title: Text
    let imageName: String
    let ctaTitle: String // 페이지별 버튼 라벨을 명시
}

struct OnboardingView: View {
    @EnvironmentObject var router: Router<AppRoute>
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        .init(
            title: Text("버스온다").foregroundColor(.green) + Text("는 저시력자를 위한\n버스 안내 앱입니다."),
            imageName: "BusImage",
            ctaTitle: "시작하기"
        ), // 1페이지도 '시작하기'로 하고 싶다면 이렇게
        .init(
            title: Text("탑승하려는 버스를 즐겨찾기하면\n버스 인식을 시작할 수 있습니다."),
            imageName: "BusCard1",
            ctaTitle: "다음"
        ),
        .init(
            title: Text("버스 인식 카메라로\n정류장에 도착한 버스를 비춰\n번호를 확인할 수 있습니다."),
            imageName: "",
            ctaTitle: "다음"
        ),
        .init(
            title: Text("즐겨찾기한 버스는 홈화면에서\n빠르게 버스인식을 시작할 수 있습니다."),
            imageName: "BusCard2",
            ctaTitle: "다음"
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            OnboardingPageView(
                page: pages[currentPage],
                pageIndex: currentPage,
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
