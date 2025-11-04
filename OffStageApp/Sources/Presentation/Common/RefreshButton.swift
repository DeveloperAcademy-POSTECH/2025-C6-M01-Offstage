
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
        .accessibilityLabel(Text(L10n.Common.A11y.buttonRefresh))
    }
}

#Preview {
    @State var angle: Angle = .zero
    return RefreshButton(countdown: 10, rotationAngle: $angle, action: {})
}
