import Speech // (프로젝트 전역에서 쓰더라도 여기서 임포트해도 무방)
import SwiftUI

struct STTandTTSTestView: View {
    @EnvironmentObject var router: Router<AppRoute>
    // 뷰 생애주기 동안 한 번 생성되어 유지되는 상태 객체
    @StateObject private var speechRecognizer = STTManager()
    @StateObject private var vm = TTSManager()
    @FocusState private var isTextEditorFocused: Bool // 키보드 내리기위한 값.
    @State private var ttsText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(L10n.SttTtsTest.Ui.titleStt)

            // 인식된 텍스트 출력 영역
            // - 실시간으로 transcript가 바뀌면 화면도 즉시 갱신됨(@Published → @StateObject 바인딩)
            Group {
                if speechRecognizer.transcript.isEmpty {
                    Text(L10n.SttTtsTest.Ui.placeholderStt)
                } else {
                    Text(speechRecognizer.transcript)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .overlay( // 테두리
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )

            // 인식 시작/중지 버튼
            Button(action: {
                if speechRecognizer.isListening {
                    // 현재 듣는 중이면 정지
                    speechRecognizer.stopListening()
                } else {
                    // 듣는 중이 아니라면 시작
                    speechRecognizer.startListening()
                }
            }) {
                // 상태에 따라 라벨 토글
                Text(speechRecognizer.isListening ? L10n.SttTtsTest.Ui.buttonStopListening : L10n.SttTtsTest.Ui
                    .buttonStartListening
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent) // 눈에 띄는 기본 버튼 스타일
        }
        .padding()

        VStack {
            // 텍스트 입력
            VStack(alignment: .leading, spacing: 20) {
                Text(L10n.SttTtsTest.Ui.titleTts)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField(L10n.SttTtsTest.Ui.placeholderTts, text: $ttsText)
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.gray.opacity(0.3)))
                    .focused($isTextEditorFocused) // 키보드를 내리기 위한 포커스 모디파이어
                // 키보드를 내리기 위한 버튼
                Button(L10n.SttTtsTest.Ui.buttonDismissKeyboard) {
                    isTextEditorFocused = false
                }
                .buttonStyle(.bordered)
            }

            HStack {
                Button(L10n.SttTtsTest.Ui.buttonRead) {
                    vm.speakNow(of: ttsText)
                }
                .buttonStyle(.borderedProminent)

                Button(L10n.SttTtsTest.Ui.buttonStop) {
                    vm.stop()
                }
                .buttonStyle(.bordered)
            }
            // 컨트롤 버튼
        }
        .padding()
        .navigationTitle(Text(L10n.SttTtsTest.Ui.titleNavigation))

        Spacer()
    }
}
