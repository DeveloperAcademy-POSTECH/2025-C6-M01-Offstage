import SwiftUI

/// router와 연결되는 메인 버스 비전 뷰
struct BusVisionView: View {
    @EnvironmentObject var router: Router<AppRoute>
    // TODO: Router 수정 후 입력받아 활용 예정. 현재는 1142로 미리 값을 입력해두었습니다.
    var routeNumbers: [String] = ["1142"]

    var body: some View {
        VStack {
            BusDetectionView(routeNumbers: routeNumbers)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    // 미리보기용 Mock Router
    RouterView(router: Router<AppRoute>(root: .busvision))
}
