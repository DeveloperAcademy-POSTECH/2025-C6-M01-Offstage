import SwiftUI

struct VoiceRecognitionLegacySheet: View {
    let onComplete: () -> Void

    var body: some View {
        VStack {
            Text("음성인식 중입니다.")

            Button {
                onComplete() // 결과 확인 sheet로 전환
            } label: {
                Text("인식 완료")
                    .padding()
                    .background(Color(.primarynormal))
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
        }
    }
}
