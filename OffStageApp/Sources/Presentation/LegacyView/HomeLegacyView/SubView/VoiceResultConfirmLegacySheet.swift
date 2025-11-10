import SwiftUI

struct VoiceResultConfirmLegacySheet: View {
    let onNavigate: () -> Void

    var body: some View {
        VStack {
            Text("음성인식을 하면 내용을 확인하는 sheet 입니다.")

            Button {
                onNavigate()
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
