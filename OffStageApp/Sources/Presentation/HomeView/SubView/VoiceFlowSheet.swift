import SwiftUI

struct VoiceFlowSheet: View {
    @EnvironmentObject var router: Router<AppRouter>
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0

    var body: some View {
        Group {
            if currentPage == 0 {
                VoiceRecognitionSheet(
                    onComplete: {
                        currentPage = 1 // 다음 페이지로
                    }
                )
            } else if currentPage == 1 {
                VoiceResultConfirmSheet(
                    onNavigate: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            router.push(.businfo)
                        }
                    },
                    onShowBusList: {
                        currentPage = 2
                    },
                    onRestart: { // ✨ 새로 추가
                        currentPage = 0
                    }
                )
            } else if currentPage == 2 {
                // 2 = 버스 리스트 화면
                BusListSheet(
                    onBack: {
                        currentPage = 1 // VoiceResultConfirmSheet로 돌아가기
                    },
                    onRestart: {
                        currentPage = 0 // VoiceRecognitionSheet로 처음부터
                    },
                    onNavigate: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            router.push(.businfo)
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
