import SwiftUI

struct VoiceRecognitionLegacySheet: View {
    let onComplete: () -> Void

    var body: some View {
        VStack {
            Text("음성인식 중입니다.")

            Button {
                onComplete() // 결과 확인 sheet로 전환
            } label: {
                Text("완료")
                    .padding()
                ZStack {
                    Circle()
                        .stroke(Color(.primarynormal), lineWidth: 8)
                        .frame(width: 110, height: 110)
                    Image(systemName: "microphone")
                        .font(.system(size: 45))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
        }
    }
}
