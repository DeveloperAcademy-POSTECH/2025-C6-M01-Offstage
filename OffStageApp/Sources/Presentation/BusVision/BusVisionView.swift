import SwiftUI

struct BusVisionView: View {
    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
        VStack {
            BusDetectionView()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    // 미리보기용 Mock Router
    RouterView(router: Router<AppRoute>(root: .busvision))
}
