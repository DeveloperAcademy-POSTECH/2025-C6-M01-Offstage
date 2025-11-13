import SwiftUI

/// 비전 인식중일 때 보여줄 로딩 애니메이션뷰
struct VisionLoadingAnimationView: View {
    @State private var currentIndex = 0

    var body: some View {
        HStack(spacing: 19) {
            ForEach(0 ..< 4) { index in
                Circle()
                    .fill(Color(.primarynormal))
                    .frame(
                        width: currentIndex == index ? 16 : 12,
                        height: currentIndex == index ? 16 : 12
                    )
                    .animation(.easeInOut(duration: 0.4), value: currentIndex)
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            currentIndex = (currentIndex + 1) % 4
        }
    }
}

#Preview {
    VisionLoadingAnimationView()
}
