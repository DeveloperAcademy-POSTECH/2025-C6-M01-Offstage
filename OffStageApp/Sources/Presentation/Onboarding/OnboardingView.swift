import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var router: Router<AppRoute>
    @State private var tabSelection = 0

    var body: some View {
        VStack {
            TabView(selection: $tabSelection) {
                OnboardingWelcomeView {
                    tabSelection = 1
                }
                .tag(0)

                OnboardingPermissionsView {
                    // '다음' 버튼을 누르면 온보딩 완료 플래그를 설정하고 홈 화면으로 이동합니다.
                    UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                    router.root = .home
                }.tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("Onboarding")
        .navigationBarHidden(true)
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
    }
}

#Preview {
    RouterView(router: Router<AppRoute>(root: .onboarding))
}
