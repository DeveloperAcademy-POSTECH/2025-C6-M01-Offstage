import SwiftUI

struct SearchView: View {
    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
        VStack(spacing: 16) {
            Text("버스 검색 화면")
                .font(.largeTitle)

            Button("버스 정류장으로 이동") {
                router.push(.busstation)
            }

            Button("이전 화면으로 돌아가기 (pop)") {
                router.pop()
            }

            Button("홈으로 돌아가기 (popToRoot)") {
                router.popToRoot()
            }
        }
        .padding()
        .navigationTitle("Bus Search")
    }
}

#Preview {
    // 미리보기용 Mock Router
    RouterView(router: Router<AppRoute>(root: .search))
}
