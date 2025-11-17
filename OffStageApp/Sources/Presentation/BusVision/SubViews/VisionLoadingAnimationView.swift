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
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            currentIndex = 0 // 매 사이클마다 첫 번째 점부터 시작

            // 0.2초 간격으로 순차적으로 점 활성화
            for i in 0 ..< 4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                    currentIndex = i
                }
            }
        }
    }
}

#Preview {
    VisionLoadingAnimationView()
}
