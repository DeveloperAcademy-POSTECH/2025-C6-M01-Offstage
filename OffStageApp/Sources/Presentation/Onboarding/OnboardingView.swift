import SwiftUI

struct OnboardingPage {
    let title: Text
    let imageName: String
    let ctaTitle: String // 페이지별 버튼 라벨을 명시
}

struct OnboardingView: View {
    @EnvironmentObject var router: Router<AppRoute>
    @State private var currentPage = 0
    @State private var didFinishOnboarding = false
    private let startPage = OnboardingPage(
        title: Text("버스온다")
            .foregroundColor(Color(red: 229 / 255, green: 255 / 255, blue: 0 / 255)) + Text("는 저시력자를 위한\n버스 안내 앱입니다."),
        imageName: "BusImage",
        ctaTitle: "알아보기"
    )

    private let pages: [OnboardingPage] = [
        .init(
            title: Text("탑승하려는 버스를 즐겨찾기\n하면 버스 인식을 시작할 수 있\n습니다."),
            imageName: "BusStation",
            ctaTitle: "다음"
        ),
        .init(
            title: Text("버스 인식 카메라로 버스 번호\n를 확인할 수 있습니다.\n "),
            imageName: "BusVision",
            ctaTitle: "다음"
        ),
        .init(
            title: Text("즐겨찾기한 버스는 홈화면에\n서 빠르게 버스인식을 할 수 있\n습니다."),
            imageName: "BusHome",
            ctaTitle: "다음"
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
    RouterView(router: Router<AppRoute>(root: .onboarding))
}
