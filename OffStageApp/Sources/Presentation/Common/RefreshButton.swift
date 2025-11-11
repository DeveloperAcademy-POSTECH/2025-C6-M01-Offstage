
import SwiftUI

struct RefreshButton: View {
    let countdown: Int?
    @Binding var rotationAngle: Angle
    let action: () -> Void

    init(countdown: Int? = nil, rotationAngle: Binding<Angle>, action: @escaping () -> Void) {
        self.countdown = countdown
        _rotationAngle = rotationAngle
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Image(systemName: "arrow.trianglehead.clockwise")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .rotationEffect(rotationAngle)

                if let countdown {
                    Text("\(countdown)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
        .accessibilityLabel("새로고침 버튼")
        .accessibilityHint("새로 고침 하려면 두번 탭하십시오.")
    }
}

#Preview {
    @State var angle: Angle = .zero
    return RefreshButton(countdown: 10, rotationAngle: $angle, action: {})
}
