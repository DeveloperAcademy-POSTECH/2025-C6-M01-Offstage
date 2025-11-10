import SwiftUI

struct BusVisionNewView: View {
    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
        Button {
            router.popToRoot()
        } label: {
            ZStack {
                Circle()
                    .stroke(Color(.primarynormal), lineWidth: 8)
                    .background(.black)
                    .frame(width: 110, height: 110)
                Image(systemName: "xmark")
                    .font(.system(size: 45))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
    }
}
