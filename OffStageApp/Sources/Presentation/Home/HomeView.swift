import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
        VStack(spacing: 16) {
            Text("메인 화면")
                .font(.largeTitle)

            Button("버스 검색으로 이동") {
                router.push(.search)
            }

            Button("버스 정류장으로 이동") {
                router.push(.busstation)
            }

            Button("비전 버스 켜기") {
                router.push(.busvision)
            }

            Button("홈 편집하기") {
                router.push(.homeedit)
            }
        }
        .padding()
        .navigationTitle("Home")
    }
}

#Preview {
    // 미리보기용 Mock Router
    RouterView(router: Router<AppRoute>(root: .home))
}
