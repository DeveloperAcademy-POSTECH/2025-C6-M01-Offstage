import SwiftUI

struct VoiceFlowSheet: View {
    @EnvironmentObject var router: Router<AppRoute>
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0

    var body: some View {
        Group {
            if currentPage == 0 {
                VoiceRecognitionLegacySheet(
                    onComplete: {
                        currentPage = 1 // 다음 페이지로
                    }
                )
            } else if currentPage == 1 {
                VoiceResultConfirmLegacySheet(
                    onNavigate: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            router.push(.businfolegacy)
                        }
                    }
                )
            }
        }
        .animation(.easeInOut, value: currentPage) // 🔑 애니메이션!
        .transition(.slide) // 옵션: 슬라이드 전환
    }
}

#Preview {
    VoiceFlowSheet()
}
