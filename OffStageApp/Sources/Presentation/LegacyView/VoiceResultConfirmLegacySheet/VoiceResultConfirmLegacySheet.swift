import SwiftUI

struct VoiceResultConfirmLegacySheet: View {
    @EnvironmentObject var router: Router<AppRoute>
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text("음성인식을 하면 내용을 확인하는 sheet 입니다.")

            Button {
                dismiss() // Sheet 먼저 닫기
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    router.push(.businfolegacy)
                }
            } label: {
                Text("버스 정보 보기")
                    .padding()
                    .background(Color(.primarynormal))
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
        }
    }
}

#Preview {
    VoiceResultConfirmLegacySheet()
}
