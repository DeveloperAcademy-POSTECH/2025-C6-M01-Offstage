import SwiftUI

struct BusListSheet: View {
    let onBack: () -> Void
    let onRestart: () -> Void
    let onNavigate: () -> Void

    var body: some View {
        VStack {
            HStack {
                Button {
                    onBack() // 이전 페이지로
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                Spacer()
                Text("버스 목록")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()

            // 버스 리스트 내용
            List {
                ForEach(0 ..< 5) { index in
                    Button {
                        onNavigate() // 버스 정보로 이동
                    } label: {
                        HStack {
                            Text("\(index + 1)번 버스")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                }
            }

            // ✨ 다시 음성인식하기 버튼
            Button {
                onRestart() // 처음부터 (VoiceRecognitionSheet)
            } label: {
                HStack {
                    Image(systemName: "microphone")
                    Text("다시 음성인식하기")
                }
                .padding()
                .background(Color(.primarynormal))
                .foregroundColor(.black)
                .cornerRadius(10)
            }
            .padding()
        }
    }
}
