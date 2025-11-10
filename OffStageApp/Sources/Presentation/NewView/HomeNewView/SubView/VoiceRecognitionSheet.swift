import SwiftUI

struct VoiceRecognitionSheet: View {
    let onComplete: () -> Void

    var body: some View {
        VStack {
            Text("번호를 듣는 중이에요.")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 30)

            Button {
                onComplete() // 결과 확인 sheet로 전환
            } label: {
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
