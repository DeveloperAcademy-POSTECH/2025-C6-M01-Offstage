import SwiftUI

struct VoiceResultConfirmSheet: View {
    let onNavigate: () -> Void
    let onShowBusList: () -> Void
    let onRestart: () -> Void

    var body: some View {
        VStack {
            Text("타려는 버스 번호가\n207번이 맞나요?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 30)

            Button {
                onNavigate()
            } label: {
                Text("네, 맞아요.")
                    .padding()
                    .background(Color(.primarynormal))
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }

            Button {
                onShowBusList()
            } label: {
                Text("버스 목록 보기")
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
            // ✨ 다시 음성인식하기 버튼
            Button {
                onRestart()
            } label: {
                HStack {
                    Image(systemName: "microphone")
                    Text("다시 음성인식하기")
                }
                .padding()
                .background(Color(.systemGray3))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}
