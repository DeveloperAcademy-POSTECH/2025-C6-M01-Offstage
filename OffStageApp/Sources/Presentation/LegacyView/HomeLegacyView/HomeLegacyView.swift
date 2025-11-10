import SwiftUI

struct HomeLegacyView: View {
    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
        Text("HomeView 입니다.")

        Button {} label: {
            Text("Sheet 띄우기")
        }
    }
}

#Preview {
    HomeLegacyView()
}
