import SwiftUI

struct BusInfoLegacyView: View {
    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
        VStack {
            Text("버스에 대한 정보를 인식하는 뷰 입니다.")
            Button {
                router.push(.busvisionlegacy)
            } label: { Text("비전버스 이동") }
        }
    }
}

#Preview {
    BusInfoLegacyView()
}
